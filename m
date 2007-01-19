From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 06/14] SUNRPC: introduce rpcbind: replacement for
	in-kernel portmapper
Date: Fri, 19 Jan 2007 00:09:52 +0000
Message-ID: <20070119000952.GB13473@infradead.org>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233012.23310.70826.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1141146948=="
Cc: trond.myklybust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7hKP-0007ZR-4z
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:09:57 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7hKP-00066B-Jf
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:09:58 -0800
To: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20070118233012.23310.70826.stgit@localhost.localdomain>
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

--===============1141146948==
Content-Type: text/plain; charset=unknown-8bit
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 18, 2007 at 06:30:12PM -0500, Chuck Lever wrote:
> Introduce a replacement for the in-kernel portmapper client that suppor=
ts
> all 3 versions of the rpcbind protocol.  This code is not used yet.
>=20
> Original code by Groupe Bull updated for the latest kernel, with multip=
le
> bug fixes.
>=20
> Note that rpcb_clnt.c does not yet support registering via versions 3 a=
nd
> 4 of the rpcbind protocol.

I don't quite like the way you introduce rcpbind.  It exports the same
API as the old portmap service, just using the rpcb_ prefix instead
of rpc_.  Why don't you transpar=E6ntly switch over the implementation to
the new model?


More comments on the actual code:

> --- /dev/null
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -0,0 +1,539 @@
> +/*
> + * linux/net/sunrpc/rpcb_clnt.c

Please don't mention the filename in the top of file comment.  It's usele=
ss
and even worse easily gets out of sync and confuses people then.

> +static inline struct rpcbind_args *rpcb_map_alloc(void)
> +{
> +	return kzalloc(sizeof(struct rpcbind_args), GFP_ATOMIC);
> +}
> +
> +static inline void rpcb_map_free(struct rpcbind_args *map)
> +{
> +	kfree(map);
> +}

Please kill these useless wrappers.

> +static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *s=
rvaddr, int proto, int version, int privileged)

Please make sure to properly break lines after 80 chars.



--===============1141146948==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1141146948==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1141146948==--
