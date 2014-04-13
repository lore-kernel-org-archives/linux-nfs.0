Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:63753 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbaDMO2I convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Apr 2014 10:28:08 -0400
Received: by mail-ig0-f178.google.com with SMTP id hn18so2496865igb.5
        for <linux-nfs@vger.kernel.org>; Sun, 13 Apr 2014 07:28:08 -0700 (PDT)
Content-Type: text/plain; charset=GB2312
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] NFS: add FATTR4_WORD1_MODE flags for cache_consistency_bitmask
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <534A8CEF.6000609@gmail.com>
Date: Sun, 13 Apr 2014 10:28:05 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <505345D4-4F7C-4970-9EBF-7CFC367575B2@primarydata.com>
References: <534A8CEF.6000609@gmail.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 13, 2014, at 9:11, Kinglong Mee <kinglongmee@gmail.com> wrote:

> After writing data at NFS client, file's access mode is inconsistent
> with server.
> Because WRITE proceduce changes the S_ISUID and S_ISGID bits,
> but client don't get it.
> 
> #touch hello; chmod 06777 hello; stat hello;
>  File: ¡®hello¡¯
>  Size: 0               Blocks: 0          IO Block: 262144 regular
> empty file
> Device: 24h/36d Inode: 786434      Links: 1
> Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
> Context: system_u:object_r:nfs_t:s0
> Access: 2014-04-13 21:00:44.996908708 +0800
> Modify: 2014-04-13 21:00:44.996908708 +0800
> Change: 2014-04-13 21:00:45.033908705 +0800
> Birth: -
> 
> #echo 12324 > hello; stat hello; stat /nfstest/hello
>  File: ¡®hello¡¯
>  Size: 6               Blocks: 0          IO Block: 262144 regular file
> Device: 24h/36d Inode: 786434      Links: 1
> Access: (6777/-rwsrwsrwx)  Uid: (    0/    root)   Gid: (    0/    root)
>         ^^^^^ it should be 0777
> Context: system_u:object_r:nfs_t:s0
> Access: 2014-04-13 21:00:44.996908708 +0800
> Modify: 2014-04-13 21:00:45.061908703 +0800
> Change: 2014-04-13 21:00:45.061908703 +0800
> Birth: -
>  File: ¡®/nfstest/hello¡¯
>  Size: 6               Blocks: 8          IO Block: 4096   regular file
> Device: 803h/2051d      Inode: 786434      Links: 1
> Access: (0777/-rwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
>         ^^^^^ bits on the server
> Context: system_u:object_r:default_t:s0
> Access: 2014-04-13 21:00:44.996908708 +0800
> Modify: 2014-04-13 21:00:45.061908703 +0800
> Change: 2014-04-13 21:00:45.061908703 +0800
> Birth: -
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
> fs/nfs/nfs4proc.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 397be39..f234af7 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2819,7 +2819,7 @@ static int _nfs4_server_capabilities(struct
> nfs_server *server, struct nfs_fh *f
> 
> 		memcpy(server->cache_consistency_bitmask, res.attr_bitmask,
> sizeof(server->cache_consistency_bitmask));
> 		server->cache_consistency_bitmask[0] &=
> FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
> -		server->cache_consistency_bitmask[1] &=
> FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
> +		server->cache_consistency_bitmask[1] &=
> FATTR4_WORD1_MODE|FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
> 		server->cache_consistency_bitmask[2] = 0;
> 		server->acl_bitmask = res.acl_bitmask;
> 		server->fh_expire_type = res.fh_expire_type;
> -- 
> 1.9.0
> 

Instead of requesting a new attribute on each and every operation just in order to deal with an extremely rare corner case, is there any reason why we can¡¯t just do this by checking should_remove_suid(), clearing the mode bits ourselves, and then marking the attributes for revalidation?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

