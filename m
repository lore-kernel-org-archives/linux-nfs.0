From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix resource leak resulting in module refcount
	leak for rpcsec_gss_krb5.ko
Date: Fri, 4 May 2007 13:25:10 -0400
Message-ID: <20070504172510.GF10434@fieldses.org>
References: <1178230502.2977.7.camel@dyn9047022153>
	<20070503224012.GK22069@fieldses.org>
	<1178294372.3621.13.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, NFS List <nfs@lists.sourceforge.net>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hk1Ws-0003Xc-Mj
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 10:25:14 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hk1Wu-0007n8-2r
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 10:25:17 -0700
In-Reply-To: <1178294372.3621.13.camel@dyn9047022153>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, May 04, 2007 at 08:59:32AM -0700, Frank Filz wrote:
> I have been investigating a module reference count leak on the server
> for rpcsec_gss_krb5.ko. It turns out the problem is a reference count
> leak for the security context in net/sunrpc/auth_gss/svcauth_gss.c.
> 
> The problem is that gss_write_init_verf() calls gss_svc_searchbyctx()
> which does a rsc_lookup() but never releases the reference to the
> context. There is another issue that rpc.svcgssd sets an "end of time"
> expiration for the context
> 
> By adding a cache_put() call in gss_svc_searchbyctx(), and setting an
> expiration timeout in the downcall, cache_clean() does clean up the
> context and the module reference count now goes to zero after unmount.
> 
> I also verified that if the context expires and then the client makes a
> new request, a new context is established.
> 
> Here is the patch to fix the kernel, I will start a separate thread to
> discuss what expiration time should be set by rpc.svcgssd.
> 
> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>

Thanks!

Acked-by: "J. Bruce Fields" <bfields@citi.umich.edu>

(And applied to my tree.)  A nit:

> @@ -932,7 +933,9 @@ gss_write_init_verf(struct svc_rqst *rqstp, struct
> rsi *rsip)

That line got wrapped, so has to be fixed up by hand before the patch
will apply.  Probably there's some setting in your mail client to fix
that for next time....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
