From: Andrew Ryan <andrewr@collab.net>
Subject: Re: some programs hang when run over nfs.
Date: Tue, 09 Apr 2002 17:54:13 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CB38D35.16746195@collab.net>
References: <Pine.LNX.4.33.0204091719490.18654-100000@minstrel.m2n.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from laswell.sfo.collab.net ([64.125.134.138])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16v6Ig-0000Ex-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Apr 2002 17:49:26 -0700
To: Todd Weaver <todd@m2n.com>
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

Todd Weaver wrote:

>
> I can run programs such as nautilus, staroffice, openoffice as a local
> user just fine. However, if I try to run any of the above programs as a
> nis user who's home directory is an nfs mount, that program will hang.
>
> for example (staroffice):
> todd@ws04~ $ strace -f /usr/local/office/program/soffice
> [snip]
> [pid   589] open("/home/t/todd/.sversionrc", O_RDONLY) = 3
> [pid   589] fcntl(3, F_GETFD)           = 0
> [pid   589] fcntl(3, F_SETFD, FD_CLOEXEC) = 0
> [pid   589] fcntl(3, F_SETLKW, {type=F_RDLCK, whence=SEEK_SET, start=0, len=0}

I've seen software hang doing a fcntl(F_SETLKW) on an NFS-mounted file when lockd
was not running or was firewalled off. Essentially the client is asking for a
lock on a file -- which it never gets -- and the app waits forever for lockd to
respond.

I would check that lockd is running on the client and server, with rpcinfo -p,
and that it is not firewalled off.



andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
