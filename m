Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:39643 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbeC2Grw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Mar 2018 02:47:52 -0400
Received: by mail-it0-f67.google.com with SMTP id e98-v6so6603270itd.4
        for <linux-nfs@vger.kernel.org>; Wed, 28 Mar 2018 23:47:52 -0700 (PDT)
Subject: Re: [PATCH v2] NFSv3/acl: forget acl cache after setattr
To: chendt <chendt.fnst@cn.fujitsu.com>, linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Benjamin Coddington <bcodding@redhat.com>
References: <ca4d7366-bc4c-1710-13a2-f99510c53be4@cn.fujitsu.com>
 <2a720d30-6471-5352-56a3-3d615bff5352@cn.fujitsu.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <54df3c51-73c5-c803-f89c-45f9d4e1c24b@gmail.com>
Date: Thu, 29 Mar 2018 14:47:41 +0800
MIME-Version: 1.0
In-Reply-To: <2a720d30-6471-5352-56a3-3d615bff5352@cn.fujitsu.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 2018/3/29 14:01, chendt wrote:
> Sync of ACL with std permissions fail，We need to forget the ACL cache after setattr.
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
> ls -l testfile
> chacl -l testfile
> 
> Output：
> -rw-rwxrw- 1 root root 0 Mar 28 05:29 testfile
> testfile [u::r--,g::rwx,o::rw-]
> 
> Signed-off-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>
> Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/nfs3proc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> index 7327930..fcb0c40 100644
> --- a/fs/nfs/nfs3proc.c
> +++ b/fs/nfs/nfs3proc.c
> @@ -139,6 +139,8 @@
>  	nfs_fattr_init(fattr);
>  	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
>  	if (status == 0)
> +		if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
> +			nfs_zap_acl_cache(inode);
>  		nfs_setattr_update_inode(inode, sattr, fattr);

Missing { } after if (status == 0) ?

thanks,
Kinglong Mee

>  	dprintk("NFS reply setattr: %d\n", status);
>  	return status;
> 
