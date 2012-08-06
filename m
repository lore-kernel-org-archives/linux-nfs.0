Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756442Ab2HFOWB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Aug 2012 10:22:01 -0400
Message-ID: <501FD300.40003@RedHat.com>
Date: Mon, 06 Aug 2012 10:21:52 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Karel Zak <kzak@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils: Something is wrong in is_vers4()
References: <20120731165842.08017d60@notabene.brown> <5018103A.9070607@RedHat.com> <20120731183739.GA16347@x2.net.home> <5019499C.2040805@RedHat.com> <20120802102142.10be27f4@notabene.brown>
In-Reply-To: <20120802102142.10be27f4@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/01/2012 08:21 PM, NeilBrown wrote:
> is_vers4 in mount_libmount.c is based on nfs_umount_is_vers4
> in nfsumount.c, except the return values are reversed.
> The result of this is:
>  - a MOUNT_UMNT call is not sent when an NFSv3 or NFSv2
>    filesystem is unmounted
>  - a MOUNT_UMNT call *is* sent when and 'nfs4' filesystem
>    is unmounted (but not when an 'nfs -o vers=4 filesystem
>    is unmounted, as that is checked elsewhere).
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed...

steved.

> 
> diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
> index ddf61b2..701d41e 100644
> --- a/utils/mount/mount_libmount.c
> +++ b/utils/mount/mount_libmount.c
> @@ -140,14 +140,14 @@ static int try_mount(struct libmnt_context *cxt, int bg)
>  	return ret;
>  }
>  
> -/* returns: error = -1, success = 0 , unknown = 1 */
> +/* returns: error = -1, success = 1 , not vers4 == 0 */
>  static int is_vers4(struct libmnt_context *cxt)
>  {
>  	struct libmnt_fs *fs = mnt_context_get_fs(cxt);
>  	struct libmnt_table *tb = NULL;
>  	const char *src = mnt_context_get_source(cxt),
>  		   *tgt = mnt_context_get_target(cxt);
> -	int rc = 1;
> +	int rc = 0;
>  
>  	if (!src || !tgt)
>  		return -1;
> @@ -163,7 +163,7 @@ static int is_vers4(struct libmnt_context *cxt)
>  	if (fs) {
>  		const char *type = mnt_fs_get_fstype(fs);
>  		if (type && strcmp(type, "nfs4") == 0)
> -			rc = 0;
> +			rc = 1;
>  	}
>  	mnt_free_table(tb);
>  	return rc;
