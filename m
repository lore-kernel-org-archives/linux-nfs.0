From: Spencer Shepler <spencer.shepler@sun.com>
Subject: Re: Stale fcntl lock never released
Date: Tue, 24 Jun 2003 15:03:10 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF8CA9E.FB84DEEF@sun.com>
References: <20030623221405.GA4320@async.com.br> <shshe6fti31.fsf@charged.uio.no> <20030624190723.GF3168@async.com.br> <16120.41730.980704.566001@charged.uio.no> <20030624191830.GG3168@async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, NFS@lists.sourceforge.net,
   Guilherme Salgado <salgado@async.com.br>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Christian Reis <kiko@async.com.br>
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


Some server implementations provide a administrative command 
to release NFS locks held at the server for a specific client
for this scenario where the client is turned off or will never
contact the server again.

Spencer

Christian Reis wrote:
> 
> On Tue, Jun 24, 2003 at 09:14:10PM +0200, Trond Myklebust wrote:
> > >>>>> " " == Christian Reis <kiko@async.com.br> writes:
> >
> >      > What if the client never reboots, but instead is turned off and
> >      > another client turned on? Should the lock persist? For how
> >      > long?
> >
> > It will persist forever.
> 
> How odd.
> 
> Is the only solution is to restart the server-side statd, or knfsd?
> 
> Take care,
> --
> Christian Reis, Senior Engineer, Async Open Source, Brazil.
> http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU Hosting Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
> INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
