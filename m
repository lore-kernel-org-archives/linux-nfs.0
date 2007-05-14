From: Martin Knoblauch <knobi@knobisoft.de>
Subject: Strange performance problems between Linux client and
	Sun/Solaris-10 Server with SAM-FS
Date: Mon, 14 May 2007 04:14:10 -0700 (PDT)
Message-ID: <758936.68723.qm@web32601.mail.mud.yahoo.com>
Reply-To: knobi@knobisoft.de
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnYVN-0001KF-9r
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 04:14:17 -0700
Received: from web32601.mail.mud.yahoo.com ([68.142.207.228])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HnYVO-0002mX-Co
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 04:14:20 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

 we are fighting with a strange performance problem when accessing a
Sun/Solaris-10 server from a Linux NFS client (HP DL380G4, x86_64,
RHEL4U3 user-space, various kernels from  2.6.9-34.ELsmp up to
2.9.21.1).

 The underlying FS on the Sun is SAM-FS (4.5.33) which provides HSM
capabilities. The basic layout is that the "online cache" is relatively
small on "high-speed" FC disks, while the offline data are stored on
cheapish SATA disks and high-speed tapes.

 The problem arises when accessing (reading) a file that is offline on
the Sun. In this case the so-called "stager" brings it back to the
online-cache first, while the client waits for the data to be
available.

 This works fine (staging speed up-to or larger  50 MB/sec) on:

- administrative "stage" request
- accessing the offline file on the Sun-Server itself
- accessing the offline file from a Solaris-10 NFS client

 When doing the same from the Linux Client performance drops below 10
MB/sec. Network performance itself looks good when accessing the file
"online".

 One thing that looks different when doing tcpdump/snoop traces between
the systems is that in the Linux/Solaris case the client seems to send
more READ3 requests (factor > 3) that the Server acknowledges (both in
the online and offline case). In the Solaris/Solaris case the number of
requests and acknowledgements is about the same.

 The remote filesystem is mounted NFS3/TCP with the following
parameters:

xxxx:/net/xxxx/fs03 on /net/xxxx/fs03 type nfs
(rw,hard,intr,bg,nfsvers=3,proto=tcp,timeo=600,rsize=32768,wsize=32768,addr=yy.yy.yy.yy)

 We are already talking to the Sun people, but they cannot reproduce.
So I put my hope for some insight on this list.

Cheers
Martin
PS: Please CC me on replies, as I am only getting the digest


------------------------------------------------------
Martin Knoblauch
email: k n o b i AT knobisoft DOT de
www:   http://www.knobisoft.de

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
