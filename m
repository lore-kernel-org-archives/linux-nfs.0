From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: fragment flooding and self-configuring clients
Date: Thu, 27 Jun 2002 18:19:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200206271819.56101.trond.myklebust@fys.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E50D041@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Nc09-0006Vy-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Jun 2002 09:20:09 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E50D041@black.eng.netapp.com>
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

On Thursday 27 June 2002 18:17, Lever, Charles wrote:

> another thought occurred to me.  the interface to all this should
> allow the socket layer to limit rsize and wsize if there isn't
> enough space to allocate a buffer large enough.  instead of this:
>
>    xprt_setbufsize(xprt, server->wsize + 1024, server->rsize + 1024);
>
> the interface should look like:
>
>     xprt_setbufsize(xprt, server);
>
> and if the socket layer needs to, it can lower the wsize and rsize
> values accordingly.  (the magic overhead numbers should probably be
> determined by the RPC layer anyway, not by the NFS client).

No. The xprt code has no business knowing details of the internals of the NFS 
code.

Cheers,
  Trond


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
