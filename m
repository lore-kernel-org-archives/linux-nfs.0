Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46515 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755082Ab1BOOz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Feb 2011 09:55:57 -0500
Date: Tue, 15 Feb 2011 09:55:56 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [bfields@pop.test.fieldses.org: all 4c5fcc5e SQUASHME:
 pnfs-obj: use pnfs_layout_hdr and layout_segment field prefix results]
Message-ID: <20110215145556.GB29420@fieldses.org>
References: <20110211152941.GB3005@fieldses.org>
 <4D576AB1.7030106@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D576AB1.7030106@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Feb 13, 2011 at 07:22:57AM +0200, Benny Halevy wrote:
> On 2011-02-11 17:29, J. Bruce Fields wrote:
> > Is this something that only shows when pnfs is configured out, maybe?
> 
> Doesn't show up with my .config, with or without pnfs configured...

I've got:

	$ grep NFS .config
	CONFIG_NFS_FS=y
	CONFIG_NFS_V3=y
	CONFIG_NFS_V3_ACL=y
	CONFIG_NFS_V4=y
	CONFIG_NFS_V4_1=y
	CONFIG_PNFS_FILE_LAYOUT=y
	# CONFIG_PNFS_BLOCK is not set
	# CONFIG_NFS_USE_LEGACY_DNS is not set
	CONFIG_NFS_USE_KERNEL_DNS=y
	# CONFIG_NFS_USE_NEW_IDMAPPER is not set
	CONFIG_NFSD=y
	CONFIG_NFSD_DEPRECATED=y
	CONFIG_NFSD_V2_ACL=y
	CONFIG_NFSD_V3=y
	CONFIG_NFSD_V3_ACL=y
	CONFIG_NFSD_V4=y
	# CONFIG_PNFSD is not set
	CONFIG_NFS_ACL_SUPPORT=y
	CONFIG_NFS_COMMON=y

> Does this help?

Yep.--b.

> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index f08ab55..35d2567 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -33,6 +33,7 @@
>   *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>   */
>  #include <linux/file.h>
> +#include <linux/kref.h>
>  #include <linux/slab.h>
>  #include <linux/nfsd/nfs4layoutxdr.h>
>  #include <linux/nfsd4_spnfs.h>
> 
> 
> > 
> > --b.
> > 
> > ----- Forwarded message from "J. Bruce Fields" <bfields@pop.test.fieldses.org> -----
> > 
> > Date: Fri, 11 Feb 2011 02:42:18 -0500
> > From: "J. Bruce Fields" <bfields@pop.test.fieldses.org>
> > To: bfields@fieldses.org
> > Subject: all 4c5fcc5e SQUASHME: pnfs-obj: use pnfs_layout_hdr and
> > 	layout_segment field prefix results
> > 
> > 6210 all 4c5fcc5e SQUASHME: pnfs-obj: use pnfs_layout_hdr and layout_segment field prefix
> > fs/cifs/file.c: In function 'cifs_iovec_write':
> > fs/cifs/file.c:1740: warning: passing argument 6 of 'CIFSSMBWrite2' from incompatible pointer type
> > fs/cifs/cifsproto.h:343: note: expected 'unsigned int *' but argument is of type 'size_t *'
> > fs/cifs/link.c: In function 'symlink_hash':
> > fs/cifs/link.c:58: warning: 'rc' may be used uninitialized in this function
> > fs/cifs/smbencrypt.c: In function 'mdfour':
> > fs/cifs/smbencrypt.c:61: warning: 'rc' may be used uninitialized in this function
> > In file included from include/linux/nfsd/nfsd4_pnfs.h:39,
> >                  from include/linux/nfsd/nfs4layoutxdr.h:38,
> >                  from fs/nfsd/nfs4proc.c:37:
> > include/linux/nfs_xdr.h:1124: error: field 'refcount' has incomplete type
> > make[2]: *** [fs/nfsd/nfs4proc.o] Error 1
> > make[1]: *** [fs/nfsd] Error 2
> > make[1]: *** Waiting for unfinished jobs....
> > make: *** [fs] Error 2
> > make: *** Waiting for unfinished jobs....
> > 
> > started Fri Feb 11 02:22:03 EST 2011, finished Fri Feb 11 02:42:18 EST 2011
> > 
> > 
> > +-----------------------------------------+
> > |            verbose output               |
> > +-----------------------------------------+
> > 
> > ----- End forwarded message -----
