From: Marco.Schwarz@Freudenberg.de
Subject: URGENT: Problems with NFS-Root-Clients
Date: Tue, 27 Aug 2002 17:26:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <95AF67BA7F70D511829B0002A551737001C9C3@faw-e01.faw.freudenberg.de>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [153.95.95.71] (helo=itnts96.freudenberg.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jiGb-0007p3-00
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 08:28:29 -0700
Received: from fgnts03.fit.freudenberg.de (fgnts03.fit.freudenberg.de) by itnts96.freudenberg.de
 (Content Technologies SMTPRS 4.2.10) with ESMTP id <T5cf92a80db995f5f478c4@itnts96.freudenberg.de> for <nfs@lists.sourceforge.net>;
 Tue, 27 Aug 2002 17:28:23 +0200
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi,

I have some big problems with one of my servers who is home to about 35
diskless nfs-root clients. I think it is due to buggy network hardware (hub,
switch) but I am not sure about it.

Symptoms:

When booting from NFS I get the following messages on the client:

NET4: Unix domain sockets 1.0/SMP for Linux NET4.0
ds: no socket drivers loaded !
Looking up port of RPC 100003/2 on 192.168.0.235
portmap: server 192.168.0.235 mot responding, timed out !
Root-NFS: Unable to get nfsd port number from server, using default
Looking up port of RPC 100005/1 on 192.168.0.235
portmap: server 192.168.0.235 mot responding, timed out !
Root-NFS: Unable to get mountd port number from server, using default
mount: server 192.168.0.235 not responding, timed out
Root-NFS: Server returned error -5 while mounting /netclients/192.168.0.87
VFS: Unable to mount root fs via NFS, trying floppy
VFS: Insert root floppy and press ENTER

And then everything just hangs ! 

Kernel version on Server and Client is 2.4.19, no patches.

Server uses SuSE 7.3, clients are SuSE 7.2 (I have 2 other servers and some
clients in other offices, they work OK).

Any ideas as to what this could be or on how to solve the problems are much
appreciated !
(about 30 people will come back to their clients tomorrow and they will be
very unhappy if they cannot work).

Thanks in advance,
Marco Schwarz



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
