Return-Path: <SRS0=spLM=RR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E7CEC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 17:29:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 56DAB2087C
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Mar 2019 17:29:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726753AbfCNR3M (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Mar 2019 13:29:12 -0400
Received: from fieldses.org ([173.255.197.46]:60334 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726749AbfCNR3M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Mar 2019 13:29:12 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 3B8C01C84; Thu, 14 Mar 2019 13:29:12 -0400 (EDT)
Date:   Thu, 14 Mar 2019 13:29:12 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     David Howells <dhowells@redhat.com>
Cc:     viro@zeniv.linux.org.uk, Jeff Layton <jlayton@kernel.org>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 20/38] vfs: Convert nfsctl to fs_context
Message-ID: <20190314172912.GB1431@fieldses.org>
References: <155257972443.13720.11743171471060355965.stgit@warthog.procyon.org.uk>
 <155257989442.13720.9404403342947215402.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155257989442.13720.9404403342947215402.stgit@warthog.procyon.org.uk>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fine by me.

(Are these for 5.1 or 5.2?  Just wondering what to do with some other
ongoing work in the same area.  Any conflicts are probably trivial,
though, so no big deal either way.)

--b.

On Thu, Mar 14, 2019 at 04:11:34PM +0000, David Howells wrote:
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: "J. Bruce Fields" <bfields@fieldses.org>
> cc: Jeff Layton <jlayton@kernel.org>
> cc: linux-nfs@vger.kernel.org
> ---
> 
>  fs/nfsd/nfsctl.c |   33 ++++++++++++++++++++++++++-------
>  1 file changed, 26 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index f2feb2d11bae..d4eb4f34a94c 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -7,6 +7,7 @@
>  #include <linux/slab.h>
>  #include <linux/namei.h>
>  #include <linux/ctype.h>
> +#include <linux/fs_context.h>
>  
>  #include <linux/sunrpc/svcsock.h>
>  #include <linux/lockd/lockd.h>
> @@ -1146,7 +1147,7 @@ static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
>   *	populating the filesystem.
>   */
>  
> -static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
> +static int nfsd_fill_super(struct super_block *sb, struct fs_context *fc)
>  {
>  	static const struct tree_descr nfsd_files[] = {
>  		[NFSD_List] = {"exports", &exports_nfsd_operations, S_IRUGO},
> @@ -1176,15 +1177,33 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
>  #endif
>  		/* last one */ {""}
>  	};
> -	get_net(sb->s_fs_info);
> +
>  	return simple_fill_super(sb, 0x6e667364, nfsd_files);
>  }
>  
> -static struct dentry *nfsd_mount(struct file_system_type *fs_type,
> -	int flags, const char *dev_name, void *data)
> +static int nfsd_fs_get_tree(struct fs_context *fc)
> +{
> +	fc->s_fs_info = get_net(fc->net_ns);
> +	return vfs_get_super(fc, vfs_get_keyed_super, nfsd_fill_super);
> +}
> +
> +static void nfsd_fs_free_fc(struct fs_context *fc)
> +{
> +	if (fc->s_fs_info)
> +		put_net(fc->s_fs_info);
> +}
> +
> +static const struct fs_context_operations nfsd_fs_context_ops = {
> +	.free		= nfsd_fs_free_fc,
> +	.get_tree	= nfsd_fs_get_tree,
> +};
> +
> +static int nfsd_init_fs_context(struct fs_context *fc)
>  {
> -	struct net *net = current->nsproxy->net_ns;
> -	return mount_ns(fs_type, flags, data, net, net->user_ns, nfsd_fill_super);
> +	put_user_ns(fc->user_ns);
> +	fc->user_ns = get_user_ns(fc->net_ns->user_ns);
> +	fc->ops = &nfsd_fs_context_ops;
> +	return 0;
>  }
>  
>  static void nfsd_umount(struct super_block *sb)
> @@ -1198,7 +1217,7 @@ static void nfsd_umount(struct super_block *sb)
>  static struct file_system_type nfsd_fs_type = {
>  	.owner		= THIS_MODULE,
>  	.name		= "nfsd",
> -	.mount		= nfsd_mount,
> +	.init_fs_context = nfsd_init_fs_context,
>  	.kill_sb	= nfsd_umount,
>  };
>  MODULE_ALIAS_FS("nfsd");
