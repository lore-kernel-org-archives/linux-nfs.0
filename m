Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794305680;
	b=0GFTjgjCAKdz6T0zmj+X7+E7RXEtpuoUqaOhCpBcDDNIMi1eZsRJM23ADXDdoAo4xcAC
	 wmv2vHmMGwWdh8aTSTIBOQ43T0qHPG1jVZfqulafluUCJCkvVqstq+KZdcir1RUcM/pBs
	 Lt2WA0qzNymB7wD4av2VB18+4lLciDYghZ127yYO4x3Yo7Ucdq/JI6dlOQY4upVvbHQEo
	 C9SkPXkKyzO3foRPcbliRZvBPzfC5tBdBlQAGAycBvveGR58RJZWA2m1G8zsaTOEmk1gs
	 BGsuE9Cmdf/0Quhr6hFcr0iIn63wchq5H9qJ6lFcq/bSXUJutL9NvHmSpcUDgUV4PlA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794305680;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To;
	bh=9WFltYRvNkpM0HMxRLJxGiCTEiP83WtKPHu+oXy3KTg=;
	b=xDXw1/OLE7vvB73xMkiDcvuxUPYF3PZHUxB9FOYj68EJAnvfOdTctV30W3e7KR8Z7BM9
	 VgpEUKACU/5TGiyrOcaFc67davJl6fH4qMHgWwmAu2no1gTYNfIgg0WLHpZNCO7c133/2
	 hxMhLCPO9m9kZN1XnDuQkxUBcd9hnpo+MVZwUkEo/RBYOGt9XezywxttXYv/iLYovQO/W
	 axWMuQQ/jH/1BnIMmpxUCwpPnZ7a6moIqaoxM8zQWzAt/RdjJGYixgUi2NgxiAj86VaUy
	 qRsVjcVdRKOp5GEQZFwBxidrjOrWqfSZQwE8yanwSnQDHupAdOs4XY7Vmd4JUKhmlkg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=DrlQYRb4;
	arc=none smtp.remote-ip=209.85.208.44
Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E200606AA45
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 10:14:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8E200606AA45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=DrlQYRb4
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-6b547d6c07bso2304487a12.1
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 02:14:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794305678; x=1794910478; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=9WFltYRvNkpM0HMxRLJxGiCTEiP83WtKPHu+oXy3KTg=;
        b=DrlQYRb4d+FJBQLFk4gip1vdMb9pZcbFm0QRoW/O9nsnnIGk5B/dcI7komCKzkv/uM
         Uz0TTkL3EB0XOLA2v0TTxwYvqDOvah1wiwbB4uUsiRRXfj1OcdvtnHWnMQS6yfKTNN5Y
         2S+sbZpFj/oUd6OIfB1K+t4luOgmpm8MRta8dNUBz+XdEb16ui6jztHrAySR2QYDDBtW
         UcH7ksMk3kyTCuhLg24n4RSbgP43bR1MD63YWBBHbNHKba+s6Adtgd3r0iiTavTYgvkx
         vCBmyxhjfzRfUpjuhY0K7x1CK/3uUIf/0FzbTbFW5bHu/k5G1xko0Cr6O3LrrObY61iA
         y+ww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794305678; x=1794910478;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=9WFltYRvNkpM0HMxRLJxGiCTEiP83WtKPHu+oXy3KTg=;
        b=fnI4DPYrspOoObtvI/z4AKi2AOVpVxEp8znkcPFmdX3vEE/6Jdh5dLeeEwU7lm5V56
         uLf7z+wyF4NjXhO2mKIA3K51acMGg0v9yvI/SZkeG2Wc7+ZU6cRMFO7KlQ+jpdktQjGx
         diGTsRqbvQC4JeKs9isrT22MndBNOPA9m2OKSYBfwV3/AG9SifQgfK3viQeLxt2+UIHV
         Kv+dgrOFqQfrBdfcwQEIh7VdhINKDIxFbEzWY6tLf905bG6gwy+Fj+3UxUFSiSO1KaEb
         LDiz7HDtk0hGVTVC2ET/IT4dDCAU0vqWcsjIkkIemOmz9T9sZ/AMo61JvJZZC10abSJH
         aYyA==
X-Forwarded-Encrypted: i=1; AL+hErFz+HqCEwIHfJJzotwycnaosKwBajhRe84li5B59FcdYWtm7ANpIKnwAyRUTSUafSLneK3apmD96EE=@vger.kernel.org
X-Gm-Message-State: APuU4Z+ZxmWW/HJGvmVTIzjxBlf1375pwsWyB2ZdRX2U9nqdEvnQcOD9
	V+FBkkUnGgB47b9CIShXEZbHrNi8gSNpAlrFT0UlKCCuK0sir+PO95xG
X-Gm-Gg: AYBFou3cgnvijqlSwgeVHImUZkQbHR5GCqXPN8ExMNTBDUekeuKinT25rqaVCBwELhD
	cY6mNRuyi+oAtIiur5jrqwOOg1GnCa1mhR7ucEFwHSb+dhXEJothrS8La3JGVsvDx2NSafaPxl3
	+NYss7Bf257Y3bGKuQzBd3EFjX9u6lrm70lvOShO/JLtPgKGIrPwrYiXHbxZA5COe5GdtahYe7h
	oblpcB5RLOwygAQUVPA7+/TVldDuEWJQmz/ChIdSXIbIxxAZmGnM1OeMJnR2rqsZ2odKOUiKBPG
	YfJ2VQfGUpjKB+wkGRW6+ronjw/J7tpmpY9Np16W9FBYqsztK1y4uszdFLWQcktl/567Fj3JEdB
	b47i31sWv4fA9nHnCGq3+uYGAa72wJL/9LfMnlx/H/0BR1GOR85EWU5BpG3BkK8crWiDpLIUH8e
	DLD4REWL/l5G3b8nfvRcUNLKRZQGqTToKK4Mh+rR9R2otRPwq6OvUIJNJeUDZfm3j6NLP0M7OuZ
	fSOW5hI2FVv2glyDQyhm7CLX/qOkf0eWos+a4YgbooxzLn7cBmvu5N0QYpyx87VosI1KM/45NB8
	1b/21tM9GlvXqocUa3/Mf44Y3X/PJ03UeJqdTUo0bCjWxlizkf3+0hviCfs7V+SrjQzV+wRWt/t
	c1tISIcGKS/9a
X-Received: by 2002:a17:907:944d:b0:c41:4c20:5a80 with SMTP id a640c23a62f3a-c504963ce05mr189793966b.44.1794305677695;
        Tue, 10 Nov 2026 02:14:37 -0800 (PST)
Received: from localhost (178-84-201-199.dynamic.upc.nl. [178.84.201.199])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c504a593eacsm90433466b.36.2026.11.10.02.14.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Nov 2026 02:14:36 -0800 (PST)
Date: Tue, 10 Nov 2026 11:14:35 +0100
From: Amir Goldstein <amir73il@gmail.com>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>,
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-mm@kvack.org,
	bpf@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@vger.kernel.org, apparmor@lists.ubuntu.com,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org,
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev,
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-usb@vger.kernel.org, linux-erofs@lists.ozlabs.org,
	linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC 38/41] fuse: refuse files on pseudo filesystems as
 passthrough backing files
Message-ID: <avLui6Mpf8GbKbtc@amir-ThinkPad-T480>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-38-4c998976c6c7@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261110-work-loop-pseudo-v1-38-4c998976c6c7@kernel.org>

On Tue, Nov 10, 2026 at 10:14:54AM +0100, Christian Brauner wrote:
> The fuse server can register any regular file as a backing file. procfs
> and binfmt_misc files are already refused by the stacking depth check as
> both set s_stack_depth to FILESYSTEM_MAX_STACK_DEPTH. sysfs and the
> other pseudo filesystems aren't. Reads and writes of the fuse file would
> then be done on the pseudo file with the fuse server's credentials.
> Refuse files on pseudo filesystems just like loop does.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
>  fs/fuse/backing.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/fuse/backing.c b/fs/fuse/backing.c
> index 8c21a8a74efb..4e4fb810ddaa 100644
> --- a/fs/fuse/backing.c
> +++ b/fs/fuse/backing.c
> @@ -147,6 +147,9 @@ static int fuse_backing_open_file(struct fuse_conn *fc, struct fuse_backing *fb,
>  		if (inode->i_sb->s_stack_depth >= fc->max_stack_depth)
>  			return -ELOOP;
>  
> +		if (file_is_pseudo(file))
> +			return -EINVAL;
> +
>  		fb->type = FUSE_BACKING_PATH;
>  		fb->path = file->f_path;
>  		path_get(&fb->path);
> 
> -- 
> 2.53.0
> 

Reviewed-by: Amir Goldstein <amir73il@gmail.com>

