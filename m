Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753464Ab3I0Ogi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Sep 2013 10:36:38 -0400
Date: Fri, 27 Sep 2013 10:36:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 07/49] pnfsd: add pnfs export option
Message-ID: <20130927143635.GB9946@pad.fieldses.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220819-12999-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220819-12999-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is this really necessary?  What would we lose if we just used pnfs
automatically when the filesystem supports it and all other necessary
configuration is in place?

On Thu, Sep 26, 2013 at 02:40:19PM -0400, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> This is a boolean for now. When more layouttypes are supported, this can
> change to "pnfs=", similar to "sec=".
> 
> The ctl interface is not enhanced.
> 
> Note: Export option strings are not guaranteed to be present in every call to
> svc_export_parse. For example, nfs-utils-1.1.2 exportfs validates the export
> with a test call that does not include the 'pnfs' export option even though
> it is set in /etc/exports.
> 
> nfsd4_layout_verify() checks if ex_pnfs is set so the ex_pnfs check in
> check_export is not needed.
> 
> Furthermore,the pnfs_export_operations super block pointer should not be
> changed because a) it is a const and b) the exports options can be changed
> while the file system is mounted.
> 
> Remove the ex_pnfs check from check_export to prevent the pnfs_export_operations
> superblock pointer from being set to NULL.

This patch doesn't touch check_export.  Is this describing a change from
a previous version of the patch?  If so, either drop this comment or
write it in a way that will make sense to someone who hasn't seen the
previous version.

--b.


> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> [pnfsd: fix cosmetic checkpatch warnings]
> [pnfsd: test pnfs export option in check_export]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [pnfsd: fix ex_pnfs check_export bug]
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/export.c            | 6 ++++++
>  include/linux/nfsd/export.h | 1 +
>  2 files changed, 7 insertions(+)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index f26b0b9..7730dfd 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -567,6 +567,8 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
>  					if (exp.ex_uuid == NULL)
>  						err = -ENOMEM;
>  				}
> +			} else if (strcmp(buf, "pnfs") == 0) {
> +				exp.ex_pnfs = 1;
>  			} else if (strcmp(buf, "secinfo") == 0)
>  				err = secinfo_parse(&mesg, buf, &exp);
>  			else
> @@ -639,6 +641,8 @@ static int svc_export_show(struct seq_file *m,
>  				seq_printf(m, "%02x", exp->ex_uuid[i]);
>  			}
>  		}
> +		if (exp->ex_pnfs)
> +			seq_puts(m, ",pnfs");
>  		show_secinfo(m, exp);
>  	}
>  	seq_puts(m, ")\n");
> @@ -666,6 +670,7 @@ static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
>  	new->ex_fslocs.locations_count = 0;
>  	new->ex_fslocs.migrated = 0;
>  	new->ex_uuid = NULL;
> +	new->ex_pnfs = 0;
>  	new->cd = item->cd;
>  }
>  
> @@ -679,6 +684,7 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
>  	new->ex_anon_uid = item->ex_anon_uid;
>  	new->ex_anon_gid = item->ex_anon_gid;
>  	new->ex_fsid = item->ex_fsid;
> +	new->ex_pnfs = item->ex_pnfs;
>  	new->ex_uuid = item->ex_uuid;
>  	item->ex_uuid = NULL;
>  	new->ex_fslocs.locations = item->ex_fslocs.locations;
> diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
> index 7898c99..b03ceee 100644
> --- a/include/linux/nfsd/export.h
> +++ b/include/linux/nfsd/export.h
> @@ -52,6 +52,7 @@ struct svc_export {
>  	kuid_t			ex_anon_uid;
>  	kgid_t			ex_anon_gid;
>  	int			ex_fsid;
> +	int			ex_pnfs;
>  	unsigned char *		ex_uuid; /* 16 byte fsid */
>  	struct nfsd4_fs_locations ex_fslocs;
>  	int			ex_nflavors;
> -- 
> 1.8.3.1
> 
