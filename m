From: Janos Farkas <chexum+dev@gmail.com>
Subject: nfs problems with 2.6.18-rc1
Date: Thu, 13 Jul 2006 20:22:20 +0200
Message-ID: <priv$8d118c145575$b19af6759a@200607.shadow.banki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G15pi-0007hB-C4
	for nfs@lists.sourceforge.net; Thu, 13 Jul 2006 11:22:42 -0700
Received: from wr-out-0506.google.com ([64.233.184.235])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G15ph-00019N-BM
	for nfs@lists.sourceforge.net; Thu, 13 Jul 2006 11:22:42 -0700
Received: by wr-out-0506.google.com with SMTP id i28so129072wra
	for <nfs@lists.sourceforge.net>; Thu, 13 Jul 2006 11:22:38 -0700 (PDT)
To: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi!

I recently updated two (old) hosts to 2.6.18-rc1, and started noticing
weird things with the nfs mounted /home s.

I frequently face EACCESs where a few minutes ago there wasn't any
problem, and after a retry everything does work again.

An example that easily trips it is keeping mutt open
on a single mailbox file (strace -tt| grep stat):

20:04:08.393815 stat64("mailbox", {st_mode=S_IFREG|0600, st_size=401000, ...}) = 0
20:08:41.859168 stat64("mailbox", {st_mode=S_IFREG|0600, st_size=401000, ...}) = 0
20:09:30.975876 stat64("mailbox", 0xbfe8966c) = -1 EACCES (Permission denied)

This results in a bit scary "Mailbox was corrupted!" message, but
otherwise harmless.  Reopening the mailbox succeeds immediately.

A sample session with an rsync session updating files on the nfs mounted
/home/:

-----
> rsync...
receiving file list ... done
file1
rsync: close failed on "/home/path/.file1.UgEmSh": Permission denied (13)
rsync error: error in file IO (code 11) at receiver.c(628) [receiver]
rsync: connection unexpectedly closed (2490 bytes received so far) [generator]
rsync error: error in rsync protocol data stream (code 12) at io.c(471) [generator]
> rsync...
receiving file list ... done
rsync: recv_generator: failed to stat "/home/path/file2": Permission denied (13)
rsync: recv_generator: failed to stat "/home/path/file3": Permission denied (13)
rsync: recv_generator: failed to stat "/home/path/file4": Permission denied (13)
rsync: recv_generator: failed to stat "/home/path/file5": Permission denied (13)
rsync: recv_generator: failed to stat "/home/path/file6": Permission denied (13)
rsync: recv_generator: failed to stat "/home/path/file7": Permission denied (13)
-----

I also think this is related in the dmesg.  Think, because there's no
other trace of any "read error" on the disks, and the comments in
mm/filemap.c (but the message is not that much help to be sure of this).

Reducing readahead size to 28K
Reducing readahead size to 4K
Reducing readahead size to 28K
Reducing readahead size to 4K
Reducing readahead size to 28K
Reducing readahead size to 4K
Reducing readahead size to 0K

The relevant part of the /proc/mounts file:

-----
automount(pid1831) /home autofs rw 0 0
HOST:/export/PATH /home/path nfs rw,vers=3,rsize=8192,wsize=8192,hard,intr,nolock,proto=udp,timeo=7,retrans=3,sec=sys,addr=HOST 0 0
-----

How can I help with tracing this?  git bisecting on these machines takes
at least an hour per step, (and no reasonable connectivity either to
compile elsewhere much quicker).

Janos


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
