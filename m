Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:45536 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702Ab0EIQZN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 May 2010 12:25:13 -0400
Received: by bwz19 with SMTP id 19so1349538bwz.21
        for <linux-nfs@vger.kernel.org>; Sun, 09 May 2010 09:25:11 -0700 (PDT)
Message-ID: <4BE6E1E0.8020706@panasas.com>
Date: Sun, 09 May 2010 19:25:04 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, Andy Adamson <andros@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] FIXME: pnfs-post-submit: per mount layout driver
 private data
References: <4BE3166F.7060800@panasas.com> <1273173832-27786-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1273173832-27786-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/06/2010 10:23 PM, Benny Halevy wrote:
> Temporary relief until we convert to use generic device cache.
> 

[In short]
Rrrr, No! This is a complete crash. The private data is per-server but
is called per super-block. In the case of two mounts of same "server",
the user of this will:
- Leak a device cache on second mount
- Crash after close of first super block.

[The long story]
I'm commenting here for the complete series Andy's and Benny included.

What Andy tried to do was move the per super-block device cache to a
per "server" device cache. (This is the per server struct at the NFS
client side not to be confused with an NFS-server what so ever). This
is because as mandated by the Protocol each device id uniqueness is
governed by a per-server-per-client-per-layoput_type, so multiple
mounts can share the device-cache and save resources. The old code
of per-mount-point was correct only not optimal.

But he did not finish his job. Because he still calls the device
cache initialization at per-mount-point init. ->initialize_mountpoint is
called from set_pnfs_layoutdriver() which is called with a super-block
per mount-point. He went to grate length (I hope, I did not check) to
make sure only the first mount, allocates the cache, and the last mount
destroys it.

But otherwise he noticed (and Benny tried to help) that now
initialize_mountpoint is per-server, and not per-sb. Hence the pointer
to struct server. 

So the old code is now a layering violation and hence the mix-up and the bug:

- If it is a per-server? name it ->initialize_server() receiving server
  pointer, No?

- If it is a per-server then shift the all set_pnfs_layoutdriver() to
  be called once per-server construction (At the server constructor code)
  then you don't need to sync in multiple places the initialization/destruction
  of sb(s) vs. servers vs device-caches. Server struct life-cycle will govern that.

Accommodating future needs:
- In objects layout (In code not yet released) I have a per-super-block: pages-
  cache-pool, raid-engine governing struct, and some other raid related information.
  I use per-super-block because this is the most natural In the Linux VFS API. So
  global stuff per super-block directly pointed by every inode for easy (random)
  access at every API level. I could shift this to be per-server in NFS-client. I surly
  don't want it global, (Rrrrr) and per-inode is two small. I will need to work harder
  to optimize for the extra contention (or maybe not).

  So the per-server model is fine, I guess, but don't let me slave over a broken API that
  forces me to duplicate lifetime rules of things that are already taken care of, only
  not seen by the layout driver.

  If moving to a per-server model then some current structures referencing and pointing
  could change to remove the SB from the picture and directly point to server.

I know this is lots of work and who's going to do it, but I was not the one who suggested
the optimization in the first place. A per-SB is some much easier because of the Linux
environment we live in, but if we do it, it must be done right.

Boaz

> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/nfs_fs_sb.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index cad56a7..00a4e7e 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -164,6 +164,7 @@ struct nfs_server {
>  
>  #ifdef CONFIG_NFS_V4_1
>  	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
> +	void			       *pnfs_ld_data; /* Per-mount data */
>  	unsigned int			ds_rsize;  /* Data server read size */
>  	unsigned int			ds_wsize;  /* Data server write size */
>  #endif /* CONFIG_NFS_V4_1 */

