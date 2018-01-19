Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51548 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755775AbeASQ1T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Jan 2018 11:27:19 -0500
Date: Fri, 19 Jan 2018 11:27:19 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFSD: hide unused svcxdr_dupstr()
Message-ID: <20180119162719.GB12065@fieldses.org>
References: <20180119145410.1096453-1-arnd@arndb.de>
 <894D5C4E-5AC6-4E77-A318-875433D0E45D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <894D5C4E-5AC6-4E77-A318-875433D0E45D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 19, 2018 at 11:15:33AM -0500, Chuck Lever wrote:
> 
> 
> > On Jan 19, 2018, at 9:54 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > 
> > There is now only one caller left for svcxdr_dupstr() and this is inside
> > of an #ifdef, so we can get a warning when the option is disabled:
> > 
> > fs/nfsd/nfs4xdr.c:241:1: error: 'svcxdr_dupstr' defined but not used [-Werror=unused-function]
> > 
> > This adds another #ifdef around the definition.
> > 
> > Fixes: e40d99e6183e ("NFSD: Clean up symlink argument XDR decoders")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Seems OK to me, and sorry for the noise.
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

Thanks!

--b.

> 
> 
> > ---
> > fs/nfsd/nfs4xdr.c | 2 ++
> > 1 file changed, 2 insertions(+)
> > 
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index f51c9cccaf78..374a62af6034 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> > @@ -237,6 +237,7 @@ svcxdr_tmpalloc(struct nfsd4_compoundargs *argp, u32 len)
> >  * Note null-terminating in place usually isn't safe since the
> >  * buffer might end on a page boundary.
> >  */
> > +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> > static char *
> > svcxdr_dupstr(struct nfsd4_compoundargs *argp, void *buf, u32 len)
> > {
> > @@ -248,6 +249,7 @@ svcxdr_dupstr(struct nfsd4_compoundargs *argp, void *buf, u32 len)
> > 	p[len] = '\0';
> > 	return p;
> > }
> > +#endif
> > 
> > /**
> >  * savemem - duplicate a chunk of memory for later processing
> > -- 
> > 2.9.0
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
