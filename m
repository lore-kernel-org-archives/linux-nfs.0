From: Christian Reis <kiko@async.com.br>
Subject: Re: Stale fcntl lock never released
Date: Tue, 24 Jun 2003 16:07:23 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030624190723.GF3168@async.com.br>
References: <20030623221405.GA4320@async.com.br> <shshe6fti31.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net, Guilherme Salgado <salgado@async.com.br>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shshe6fti31.fsf@charged.uio.no>
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

On Tue, Jun 24, 2003 at 09:02:10PM +0200, Trond Myklebust wrote:
> >>>>> " " == Christian Reis <kiko@async.com.br> writes:
> 
>      > (Trond, do any of the lockd patches in
>      > http://www.fys.uio.no/~trondmy/src/2.4.21/ fix something like
>      > this?)
> 
> No. This is what rpc.statd is supposed to do. When a client reboots,
> it is supposed to notify the server that it should remove all locks
> belonging to that client.

What if the client never reboots, but instead is turned off and another
client turned on? Should the lock persist? For how long?

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
