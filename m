Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793055060;
	b=qFSXifX0GirRUz1wM+3kuikIma/zzGnyYPuJM9vWPQB3CSR9MX0jaVv00XMJIkUEmxdF
	 NXxovfIzrbQ2+aDYF0R2cMCC5xe7h/ApJ99s80nqmsN6CDdGCaVr4IoMEMCFLq3SjrKIK
	 MabRbFSIFLbj0b7AuyQhPtgZpXt1SZ44XpiEBG6Re2IApZoyQC9zGs81V2UTK3ACjnJ3+
	 MfIVfZHvaDc1CiN/sDzP+i5K2zA3iwAIWGuHasqCMzPdcFdR7MoBYQPWrms4gjnGWiV+l
	 gaIXpgguzO3aA5o2xeQsenJpK6OuHhZQxyA37XeHlAweToRKZXLwRx7M3OjQnReoZxg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793055060;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=tjMt5dr2gWGDrECxnpxp9ywZnq9belcTErdkR5YLT1A=;
	b=mfeqdq98dw4YkOGyi5UMHC/Bj+YpMr+9VgF1iRPypUADfVkq/TQ0fzD62NcaYwT8zsly
	 c0w1E7Wk6FJRaALBOusTsgaqTgwgMxYh5MBR+tSl8WkrIcpx5aLY+US7oWGCMPQAPnP3C
	 1eSWo58xtOFSyPtdN95vP0B/yDGxAV5f5xYilG2IanOjj+ajlHAaZsfZfvEv0ZtYsXGXd
	 fWQ5K5DdMu/C1lOnbm5qvLAx5TuUnco34nc2uuJg0lYR9e1V0tlut5UZ6OKo0jKQsGEiG
	 oVGi3vAPpGyqpviqfwQbZ16sCZEfxeuM0abKEHCeEyE2mAWhlobWP5ZfUd477JxIRcQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K239FPuc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3968606A31A
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 22:50:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K239FPuc
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 882D81F01825
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 22:50:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793055059;
	bh=tjMt5dr2gWGDrECxnpxp9ywZnq9belcTErdkR5YLT1A=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=K239FPuccObejCn8W2wrF+LS4pwAP03MkzzpTJJq9W5PpKdExc3G8gRZ01gFTCAVM
	 EG6S9AIbkS4lBiBNXwF27k9HZmlmUb55rHG72M15w2+CIGgsbfh1NGVVh4zvGq6TqH
	 rX8wvBPS51AdXkuZ7wOmIk6FsKji0EuxYc4xudlzQBLcytcBGNM1WE97JeR3GLjn36
	 WqNPDE1CUQ6FNgZAXznbaMHkYUc4XK89Uo3wuFLMMtwPzN2zrZNp4ctvKpPHzs6yx0
	 2sx0fRjcY62QEXsSOC5hOH69rt/HtDaRwNPQQ5XHCc2oVIJosr0IIK+1hCi0rU8MVh
	 CCFZD1xqdj0kw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id C7C66F40066;
	Mon, 26 Oct 2026 18:50:58 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Mon, 26 Oct 2026 18:50:58 -0400
X-ME-Sender: <xms:UtnfajEznxXnn3xzGmPWWsQioMAuSz7vZXId8KEEnojf59HFDbhA9g>
    <xme:UtnfarKlgcenpySetfB7ioiB16UH8IEg-n8XjDm54wmlRuLpCZOqWaNRvn2iKJg5p
    A-DB1_RzfC4FlqZQnuPX0fhs7nBN_1VF94IGnP8n_tx514bgkGJqFst>
X-ME-Proxy-Cause: dmFkZTFx5OR4ex25bHFlDpUv81Qn0gmMR+nXyzXVfhiMBYg7d/+SAPMuxSW4Jux9HmLtWO
    lxheHjJUoA3CsXsVngbRAge3vYV6kvMft8z7vJWCadi6L00pH1Jz4ybM44IgNM3afJP5Qe
    j13Zu3st24Rmh9akPV4ybXeNNVKB/3AJ3izKXBbybXHO5j3A8f4Bz++AvA1CKl3FHZUnSJ
    IWqeQr6aInjnfdWspzizLVU8TnCIinxMrgLad+enQkoXlmMMkCQky6HJ0D+4Lx6F0r4Zyl
    xXLdoIoeC59q23mWms+xN3Hk/qMoSkpk3s5JJFasXUyXQSGaX9Wb42hRzLaSgpxQheF8UW
    U9d2rs8uNhti4TU5YXOuVRQYw8tNqFGYVQcJ011LSDuYQsOLqnVA38NtBXjfeDTgUUyJtn
    mpmm+jhRzygcyzqWqGH9dGz1qYUUJEO6rXbVWwSZLls+g09z7572esPO5jUZ6gQ0nKVYDw
    hE4KPE48Oc/6BKsc+OLt2Kj2nUN9m/z8KbeYQlEHakOPKdNO4PjzFs4bRVvnCERrsPHnji
    7NVCJDs2/L6BDtV69pnpHXtlflbpAlDyaX1HWSpiJIiNMcOYqQVkSkidRY3kSbrOADusue
    fxq3i7FxOG87oHSNuEBeR4SYBD0kGTBVqzXvCZl6vWNozp9pTr01LbcxZ5QA
X-ME-Proxy: <xmx:UtnfatdgOKCIG177HoBXCbDfKJZyVBapJi0TREeTugWY6CsUqZ7hWA>
    <xmx:Utnfar7T5SXZfalMUXN8Rey2AV2Uo3w5dTqQqepDygYTcx4QTkdMrQ>
    <xmx:Utnfakuw9N1l2EU2qkVRPOVImnNzhb5SGjCVL0n7XlztdzTRWRZdIw>
    <xmx:UtnfarjRAzm_TmOZdi2P9GZxOwHz4xIzzwlcBuPSPj42eGUaaLQzYw>
    <xmx:Utnfavr2hQ6DdHHH7EF64t6YAOhJ6tjXBAYNSLWDuCTUdWiNL3GYDgXB>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A86FBB6006E; Mon, 26 Oct 2026 18:50:58 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: ARxNhz-O7gxF
Date: Mon, 26 Oct 2026 15:50:38 -0700
From: "Anna Schumaker" <anna@kernel.org>
To: "Chuck Lever" <cel@kernel.org>, NeilBrown <neil@brown.name>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
Message-Id: <3ed2b4d0-9ce8-4cdb-8332-d8edcda629aa@app.fastmail.com>
In-Reply-To: <20261025151622.141025-12-cel@kernel.org>
References: <20261025151622.141025-1-cel@kernel.org>
 <20261025151622.141025-12-cel@kernel.org>
Subject: Re: [PATCH v1 11/13] NFS: Move NFSACL_MAXPAGES into fs/nfs/nfs3_fs.h
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Chuck,

On Sun, Oct 25, 2026, at 8:16 AM, Chuck Lever wrote:
> Only the NFSv3 client's ACL code reads NFSACL_MAXPAGES, yet the macro
> lives in <linux/nfsacl.h>, where it is the last reference to
> NFS_ACL_MAX_ENTRIES. <linux/nfsacl.h> no longer includes
> <uapi/linux/nfsacl.h>, so a file that includes only the kernel header
> cannot expand NFSACL_MAXPAGES. Move the macro next to its users and
> include nfs3_fs.h from nfs3xdr.c.

I assume this should go through the NFSD tree with the rest of the
patch series? If so:

Acked-by: Anna Schumaker <anna.schumaker@hammerspace.com>

>
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  fs/nfs/nfs3_fs.h       | 3 +++
>  fs/nfs/nfs3xdr.c       | 1 +
>  include/linux/nfsacl.h | 3 ---
>  3 files changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/nfs3_fs.h b/fs/nfs/nfs3_fs.h
> index ffcabadb3546..09663adae033 100644
> --- a/fs/nfs/nfs3_fs.h
> +++ b/fs/nfs/nfs3_fs.h
> @@ -11,6 +11,9 @@
>   * nfs3acl.c
>   */
>  #ifdef CONFIG_NFS_V3_ACL
> +#define NFSACL_MAXPAGES		((2*(8+12*NFS_ACL_MAX_ENTRIES) + PAGE_SIZE-1) \
> +				 >> PAGE_SHIFT)
> +
>  extern struct posix_acl *nfs3_get_acl(struct inode *inode, int type, bool rcu);
>  extern int nfs3_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
>  			struct posix_acl *acl, int type);
> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index 3251c1434e71..19ab2fe84b8c 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -25,6 +25,7 @@
>  #include <linux/nfs_common.h>
> 
>  #include "internal.h"
> +#include "nfs3_fs.h"
>  #include "nfstrace.h"
> 
>  #define NFSDBG_FACILITY		NFSDBG_XDR
> diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
> index 403f5f5144e3..5160f30151e8 100644
> --- a/include/linux/nfsacl.h
> +++ b/include/linux/nfsacl.h
> @@ -10,9 +10,6 @@
>  #include <linux/posix_acl.h>
>  #include <linux/sunrpc/xdr.h>
> 
> -#define NFSACL_MAXPAGES		((2*(8+12*NFS_ACL_MAX_ENTRIES) + PAGE_SIZE-1) \
> -				 >> PAGE_SHIFT)
> -
>  #define NFS_ACL_MAX_ENTRIES_INLINE	(5)
>  #define NFS_ACL_INLINE_BUFSIZE	((2*(2+3*NFS_ACL_MAX_ENTRIES_INLINE)) << 2)
> 
> -- 
> 2.56.0
