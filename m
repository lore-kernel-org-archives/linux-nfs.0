From: =?ISO-8859-15?Q?Peter_Karl_M=FCller?= <peter.karl.mueller@gmx.de>
Subject: Linux 2.6.10: locks are leaked
Date: Tue, 29 Mar 2005 02:25:36 +0200
Message-ID: <4248A080.2020600@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DG4YD-0005a1-F5
	for nfs@lists.sourceforge.net; Mon, 28 Mar 2005 16:25:45 -0800
Received: from pop.gmx.net ([213.165.64.20] helo=mail.gmx.net)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DG4YB-0000kK-QR
	for nfs@lists.sourceforge.net; Mon, 28 Mar 2005 16:25:45 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Dear experts,

my home directories are exported from server to client (both vanilla
2.6.10). When I start the famous "skype" program from my home directory
in a console, enter my account/password, and then terminate the skype
process by ctrl-\ some file locks remain on the server. These file
locks prevent a successfull re-login after a re-launch of "skype"
(you get "Logging in failed").

I performed some tests with multiple running/stopped instances of

      1 #include <stdio.h>
      2 #include <sys/types.h>
      3 #include <sys/stat.h>
      4 #include <fcntl.h>
      5 #include <signal.h>
      6
      7 int main ()
      8 {
      9    int fd = open ("DATAFILE", O_RDWR, 0600);
     10    if (fd == -1)
     11       perror ("open"), exit (1);
     12    printf ("file opened\n");
     13    int rc = lockf (fd, F_LOCK, 0);
     14    if (rc)
     15       perror ("lockf"), exit (2);
     16    printf ("lock acquired\n");
     17    pid_t mypid = getpid ();
     18    printf ("pid = %d\n", mypid);
     19    sleep (10);
     20    kill (mypid, 9);
     21    return 0;
     22 }

and eventually ran into a well known kernel panic on the client. In two
cases the server became fully inaccessible.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
