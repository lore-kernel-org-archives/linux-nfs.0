From: Todd Weaver <todd@m2n.com>
Subject: some programs hang when run over nfs.
Date: Tue, 9 Apr 2002 17:29:38 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0204091719490.18654-100000@minstrel.m2n.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 63-224-62-148.dsl.uswest.net ([63.224.62.148] helo=mail.m2n.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16v5za-0003na-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Apr 2002 17:29:42 -0700
Received: from todd (helo=localhost)
	by mail.m2n.com with local-esmtp (Exim 3.12 #1 (Debian))
	id 16v5zW-0004tK-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Apr 2002 17:29:38 -0700
To: <nfs@lists.sourceforge.net>
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

Hello,

I thought this was a library issue per workstation for quite awhile.
However, I have narrowed it down to this problem.

I can run programs such as nautilus, staroffice, openoffice as a local
user just fine. However, if I try to run any of the above programs as a
nis user who's home directory is an nfs mount, that program will hang.

for example (staroffice):
todd@ws04~ $ strace -f /usr/local/office/program/soffice
[snip]
[pid   589] open("/home/t/todd/.sversionrc", O_RDONLY) = 3
[pid   589] fcntl(3, F_GETFD)           = 0
[pid   589] fcntl(3, F_SETFD, FD_CLOEXEC) = 0
[pid   589] fcntl(3, F_SETLKW, {type=F_RDLCK, whence=SEEK_SET, start=0, len=0}

This of course all occurred as soon as I upgraded debian stable to the
latest packages.

I am not sure how to track this problem any further.

I will add that as a local user there is no problem whatsoever.
but as a nis/nfs user some programs fail with similar results.
mozilla works fine, and obviously that is setup with a local binary, and
the configuration is read over nfs.

Could somebody please help me debug this further, or better yet tell me
what I need do to fix this problem.

I can easily provide more information, if somebody can tell me what would
be pertinent.

I am not a subscriber to the nfs mailing list (yet) so please reply to me
as well as the list please.

Thanks all!


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
