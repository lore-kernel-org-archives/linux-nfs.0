Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37562 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347Ab2E2Pb2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 11:31:28 -0400
Date: Tue, 29 May 2012 11:31:27 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Honor the no_root_squash flag on pseudo roots.
Message-ID: <20120529153127.GD3441@fieldses.org>
References: <1338296836-28243-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1338296836-28243-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 29, 2012 at 09:07:16AM -0400, Steve Dickson wrote:
> If root squashing is turned off on a export that
> has multiple directories, the parent directories
> of the pseudo exports that's built, also needs to
> have root squashing turned off.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mountd/v4root.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
> index 708eb61..ad8a3e7 100644
> --- a/utils/mountd/v4root.c
> +++ b/utils/mountd/v4root.c
> @@ -92,7 +92,14 @@ v4root_create(char *path, nfs_export *export)
>  	exp = export_create(&eep, 0);
>  	if (exp == NULL)
>  		return NULL;
> -	xlog(D_CALL, "v4root_create: path '%s'", exp->m_export.e_path);
> +	/*
> +	 * Honor the no_root_squash flag 
> +	 */
> +	if ((curexp->e_flags & NFSEXP_ROOTSQUASH) == 0)
> +		exp->m_export.e_flags &= ~NFSEXP_ROOTSQUASH;
> +	xlog(D_CALL, "v4root_create: path '%s' flags 0x%x", 
> +		exp->m_export.e_path, exp->m_export.e_flags);
> +

Whoops, good catch.

But the right place to put this is in set_pseudofs_security(), as
follows (untested).

Otherwise you'll run into the same problem in cases where subdirectories
have a mixture of root_squash and no_root_squash set.

--b.

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index 81f813b..76bda37 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -61,6 +61,8 @@ void set_pseudofs_security(struct exportent *pseudo, struct exportent *source)
 
 	if (source->e_flags & NFSEXP_INSECURE_PORT)
 		pseudo->e_flags |= NFSEXP_INSECURE_PORT;
+	if (source->e_flags & NFSEXP_ROOTSQUASH == 0)
+		pseudo->e_flags &= ~NFSEXP_ROOTSQUASH;
 	for (se = source->e_secinfo; se->flav; se++) {
 		struct sec_entry *new;
 
