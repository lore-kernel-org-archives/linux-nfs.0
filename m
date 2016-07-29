Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44724 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbcG2TEh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 15:04:37 -0400
Date: Fri, 29 Jul 2016 15:04:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 7/7] mountd: fail nfsd.export lookup for path to
 unmounted exportpoint
Message-ID: <20160729190436.GB7964@fieldses.org>
References: <146976807524.20186.8871903418718212567.stgit@noble>
 <146976861683.20186.1810009593325251793.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <146976861683.20186.1810009593325251793.stgit@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 29, 2016 at 03:03:36PM +1000, NeilBrown wrote:
> If an export point should be mounted ("mountpoint" option set) but
> isn't, then an attempt to mount using the MOUNT protocol for NFSv3
> will fail and an attempt to access the filesystem using a pre-existing
> filehandle will block because nfsd_fh wont tell the kernel about it.
> 
> However a lookup from the parent, as happens with an NFSv4 mount
> request, will pass the name to nfsd_export(), and it doesn't check the
> mointpoint option, and so exports the underlying (typically "/")
> filesystem.
> 
> So change nfsd_export() to refused to export that exportpoint, but
> instead to explictly say that it isn't exported.
> This will cause an 'ls' in the parent pseudo-root directory to not show
> the name and will cause a "mount" attempt which walks down through the
> pseudo root to fail in the same way that it does with NFSv3.
> 
> An access from a pre-existing NFSv4 mount will still hang until the
> filesystem is mounted, just like it does with NFSv3.
> 
> In order to be a bit more responsive to the filesystem getting mounted,
> just a short timeout (1 minutes) on exports of missing "mountpoint"
> exportpoints.

OK, I'm still haven't learned to love "mountpoint", but, I agree, it
looks like this fixes the complaint about the v4 case with minimal risk
of disruption to existing users.

ACK.--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  utils/mountd/cache.c |   18 +++++++++++++++++-
>  1 file changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 9cc270690d90..ca6c84f4d93d 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -1334,7 +1334,23 @@ static void nfsd_export(int f)
>  	found = lookup_export(dom, path, ai);
>  
>  	if (found) {
> -		if (dump_to_cache(f, buf, sizeof(buf), dom, path, &found->m_export, 0) < 0) {
> +		char *mp = found->m_export.e_mountpoint;
> +
> +		if (mp && !*mp)
> +			mp = found->m_export.e_path;
> +		if (mp && !is_mountpoint(mp))
> +			/* Exportpoint is not mounted, so tell kernel it is
> +			 * not available.
> +			 * This will cause it not to appear in the V4 Pseudo-root
> +			 * and so a "mount" of this path will fail, just like with
> +			 * V3.
> +			 * And filehandle for this mountpoint from an earlier
> +			 * mount will block in nfsd.fh lookup.
> +			 */
> +			dump_to_cache(f, buf, sizeof(buf), dom, path,
> +				      NULL, 60);
> +		else if (dump_to_cache(f, buf, sizeof(buf), dom, path,
> +					 &found->m_export, 0) < 0) {
>  			xlog(L_WARNING,
>  			     "Cannot export %s, possibly unsupported filesystem"
>  			     " or fsid= required", path);
> 
