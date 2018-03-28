Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:55402 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752694AbeC1Usi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Mar 2018 16:48:38 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: chendt <chendt.fnst@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org,
        "Trond Myklebust" <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] NFSv3/acl: forget acl cache after setattr
Date: Wed, 28 Mar 2018 16:48:36 -0400
Message-ID: <DE56FEF6-A0F6-4584-B6B5-517FDCE80531@redhat.com>
In-Reply-To: <ca4d7366-bc4c-1710-13a2-f99510c53be4@cn.fujitsu.com>
References: <ca4d7366-bc4c-1710-13a2-f99510c53be4@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm seeing this on xfstests generic/099 as well. Do we want to use 
nfs_zap_acl_cache() instead so that we clear NFS_INO_INVALID_ACL?

Ben

On 28 Mar 2018, at 6:12, chendt wrote:

> Sync of ACL with std permissions fail，do We need to forget the ACL
> cache after setattr?
>
> Reproduction:
> #!/bin/bash
> touch testfile
> cat <<EOF >testfile
> #!/bin/bash
> echo "Test was executed"
> EOF
> chmod u=rwx testfile
> chmod g=rw- testfile
> chmod o=r-- testfile
>
> chacl u::r--,g::rwx,o:rw- testfile
> chmod u+w testfile
> ls -ln testfile
> chacl -l testfile
>
> Output：
> -rw-rwxrw- 1 root root 0 Mar 28 05:29 testfile
> testfile [u::r--,g::rwx,o::rw-]
>
> Signed-off-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>
> ---
>  fs/nfs/nfs3proc.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> index 7327930..ef3e17c 100644
> --- a/fs/nfs/nfs3proc.c
> +++ b/fs/nfs/nfs3proc.c
> @@ -140,6 +140,7 @@
>  	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
>  	if (status == 0)
>  		nfs_setattr_update_inode(inode, sattr, fattr);
> +		forget_all_cached_acls(inode);
>  	dprintk("NFS reply setattr: %d\n", status);
>  	return status;
>  }
> -- 
> 1.8.3.1
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
