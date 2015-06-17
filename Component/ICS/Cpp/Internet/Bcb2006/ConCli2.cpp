/*---------------------------------------------------------------------------

Author:       Fran�ois PIETTE
Description:  ConCli2 shows how to use TWSocket in a console mode application.
              ConCli2 use a thread to make the socket run in the program
              background while the foreground is busy with the user interface
              (for simplicity here we just wait for the user to hit the
              enter key).
Creation:     Nov 22, 1997
Version:      1.02
Email         francois.piette@overbyte.be      http://www.overbyte.be
Support:      Use the mailing list twsocket@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 1997-2005 by Fran�ois PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@overbyte.be>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

Updates:
Apr 12, 1998 V1.01 Adapted for BCB3
Dec 19, 1998 V1.02 Do not use TWait control anymore.

---------------------------------------------------------------------------*/
#if __BORLANDC__ == 0x520     // BCB1 is BC5.20   BCB3 is BC5.30
    #define _WINSOCKAPI_      // Prevent winsock.h from being included
#endif
#include <vcl\vcl.h>
#include <stdio.h>
#include <conio.h>
#include <condefs.h>
#pragma hdrstop
#include <wsocket.hpp>

#define ServerHostName "localhost"
#define ServerPort     "telnet"
//---------------------------------------------------------------------------
class TWSocketThread : public TThread
{
private:
protected:
    TWSocket *FWSocket;
    char     FRcvBuf[1024];
    void __fastcall Execute();
    void __fastcall FWSocketDataAvailable(TObject *Sender, WORD Error);
    void __fastcall FWSocketSessionConnected(TObject *Sender, WORD Error);
    void __fastcall FWSocketSessionClosed(TObject *Sender, WORD Error);
public:
    __fastcall TWSocketThread();
};
//---------------------------------------------------------------------------
__fastcall TWSocketThread::TWSocketThread()
    : TThread(TRUE)              // Create suspended
{
    FreeOnTerminate = TRUE;
}
//---------------------------------------------------------------------------
void __fastcall TWSocketThread::Execute()
{
    // Let's the user know what we are doing
    printf("Connecting to server '" ServerHostName
           "' on port '" ServerPort "'\n");

    // Create the TWSocket we will use to commicate with the server
    FWSocket                    = new TWSocket((void *)NULL);

    // Assign the event handler for the TWSocket events we care of
    FWSocket->OnDataAvailable    = FWSocketDataAvailable;
    FWSocket->OnSessionClosed    = FWSocketSessionClosed;
    FWSocket->OnSessionConnected = FWSocketSessionConnected;

    // Connect to the server
    FWSocket->Addr     = ServerHostName;
    FWSocket->Port     = ServerPort;
    FWSocket->Proto    = "tcp";
    FWSocket->Connect();

    // Let the TWSocket component makes his work
    FWSocket->MessageLoop();

    // We are done, destroy the objects we created
    delete FWSocket;
}
//---------------------------------------------------------------------------
// This event handler is called by the TWSocket when some data has been
// received by the lower level.
void __fastcall TWSocketThread::FWSocketDataAvailable(TObject *Sender, WORD Error)
{
    int Len;

    // Get the received data
    Len = FWSocket->Receive(FRcvBuf, sizeof(FRcvBuf) - 1);
    if (Len <= 0)
        return;

    // Add a terminating nul byte to allow display using standard I/O
    FRcvBuf[Len] = 0;
    printf("%s", FRcvBuf);
}
//---------------------------------------------------------------------------
// This event handler is called by TWSocket when the connection is
// established with the remote host
void __fastcall TWSocketThread::FWSocketSessionConnected(
    TObject *Sender, WORD Error)
{
    if (Error == 0) {
        printf("Connected\n");
    } else {
        printf("Unable to connect. Error %d\n", Error);
    }
}
//---------------------------------------------------------------------------
// This event handler is called by TWSocket when the connection is broken
void __fastcall TWSocketThread::FWSocketSessionClosed(TObject *Sender, WORD Error)
{
    printf("Server has diconnected\n");
    FWSocket->Close();
}
//---------------------------------------------------------------------------
void main(void)
{
    TWSocketThread *WSocketThread;

    printf("Hit enter to stop the program\n");

    // Create the socket working thread (suspended)
    WSocketThread = new TWSocketThread;

    // Start the thread
    WSocketThread->Resume();

    // The main thread continue here. Process user request here.
    getch();

    // We are done, quit the program
    printf("Ok.\n");
}
//---------------------------------------------------------------------------


