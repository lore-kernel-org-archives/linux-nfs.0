From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
Date: Mon, 28 Jul 2003 10:56:08 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16164.29864.268358.781865@gargle.gargle.HOWL>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
	<20030727163124.GC19877@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19gwJE-0000Mi-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Jul 2003 17:56:16 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Mon, 28 Jul 2003 10:56:08 +1000
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Sunday July 27
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Sunday July 27, chip@pobox.com wrote:
> I confess I don't quite understand this bug report.  Is this person
> asking for something that NFS can't do, or is there perhaps some error
> in configuration ... ?
> 
> Please advise.

This is something that NFS *can* do, so it's either a config error or
a source-code error...

When the server gets a lock request from a client, it asked the local
statd to monitor that client.
The server-statd contacts the client-statd and tells it that it wants
to know about reboot.  The client-statd record the address of the
server in /var/lib/nfs/sm/ as a new empty file.
Only if this succeeds does the server grant the lock.

When the client reboots, statd will be restarted and will move all
files from .../sm/ to .../sm.bak/ and will then iterate through those
files sending a message to statd on the relevant servers telling them
that a reboot has happened.
The server-statd will, on receipt of this message, tell the
server-lockd that the client has rebooted, and lockd will release all
the locks.

I just tried this and it worked (2.4.19/21 kernels and nfs-utils 1.0.5)
so it doesn't seem to be a source-code error.

The mostly likely config error is not running statd on the client.
i.e. not having nfs-common installed.  But given that the bug was
reported against nfs-common, that seems unlikely in this case.

The next mosty likely would be tcpwrappers problems.
I notice that the man page for statd says that "You have to give the
clients access to rpc.statd", but ofcourse you need to give the server
access to statd on the clients aswell.

In order for the server to allow a lock from the client,  statd on
the client must allow access from the server.
In order for the client to be able to revoke locks on reboot, statd on
the server must allow access from the client.

It is possible that the problem is caused by the server not allowing
statd requests from the client.

Looking at the tcp_wrapper stuff used by statd, it looks rather bogus(*),
though I think it is more likely to give away access that it shouldn't
rather than restrict access that it should grant.

Anyway, I suggest that the person having the problem tries:

    rpcinfo -u SERVERNAME status
from the client, and

    rpcinfo -u CLIENTNAME status
from the server
and checks that both works.  If either doesn't I suspect that is the
problem. If they both work.... I don't know.


(*) good_client in tcp_wrapper.c calls hosts_ctl twice, once with IP
address and once with hostname.  If the first successed, the second
isn't tried.

So if my hosts.deny says that a specific hostname is restricted, but
doesn't say the IP address is restricted, then access is granted.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
