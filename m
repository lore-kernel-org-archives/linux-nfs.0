From: Todd Weaver <todd@m2n.com>
Subject: Re: some programs hang when run over nfs.
Date: Tue, 9 Apr 2002 18:08:24 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0204091807310.19524-100000@minstrel.m2n.com>
References: <3CB38D35.16746195@collab.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 63-224-62-148.dsl.uswest.net ([63.224.62.148] helo=mail.m2n.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16v6bI-00066C-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Apr 2002 18:08:40 -0700
To: Andrew Ryan <andrewr@collab.net>
In-Reply-To: <3CB38D35.16746195@collab.net>
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

On Tue, 9 Apr 2002, Andrew Ryan wrote:
> I've seen software hang doing a fcntl(F_SETLKW) on an NFS-mounted file
> when lockd was not running or was firewalled off. Essentially the
> client is asking for a lock on a file -- which it never gets -- and
> the app waits forever for lockd to respond.
>
> I would check that lockd is running on the client and server, with
> rpcinfo -p, and that it is not firewalled off.

Much appreciate the help!

todd@ws04~ $ rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp   1024  nlockmgr
    100021    3   udp   1024  nlockmgr
    100007    2   udp    791  ypbind
    100007    1   udp    791  ypbind
    100007    2   tcp    794  ypbind
    100007    1   tcp    794  ypbind
    100024    1   udp    777  status
    100024    1   tcp    779  status
todd@ws04~ $

I'm looking into how to get lockd running. (or can you help with that
too?)


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
