Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.215.170
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794686761;
	b=5Qnsx6c25dMXjjuRkACTpEumlL9JLzaibQSgHNinW1XGW2VxY7Dfm2XZgNNvkZ2FJjjg
	 XNm4SQ47HoOZq8ebUi9fhi+xKoD+4YD7Vie9GJVR27MU4Wd1Ftl2V6x5k7cBGDDFG0pYk
	 3uDqXUkL5/tANsGqFm7vymY4lppV/94JxvP6lNeRtrMekAs9Ryj3M3pkC6hUo2B4M9faD
	 F9AOP59RZFWhCBiO5J/RjNi2oyC1ZrxSlRMhcG76YEDaQG8vyHiRzPvqJZk3xRvZdgAM3
	 Xc7ZCXB9LTMfkCnazx1KEwATvXHMQCCjPDEGgXMOctcmN7k4QyoSD00iSDnDLN+M3vw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794686761;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Date:From:To:Cc:Subject:In-Reply-To:References:MIME-Version:
	 Content-Type:Content-Disposition:Message-ID:User-Agent;
	bh=L9fh6nGpkdQ3PKE1Pv6VuACg3WWhS00/MicQv00SggM=;
	b=MDvdP9f2YV+o41TVmtgDgG3X87PsVJgSWVlybP95DkFl0FZ25zH4ydMG3V3ODSWU8PBh
	 +h87CV7j3LNiS91uBTdmzP0IxNtKrjuP75H4+BokAf7WiCYNa/EzxZsHc6hkMdrH7ABe2
	 hG4K95Zh9PFd5iSjU2rrjEi5pVHjkYLDwIDxRROoXRGxo597Jm3O/R0DsHyaJzLYxcsxr
	 p7IG+el7rGi0Ey+2fDWGnodKQ/TPQbWJVa1i54W98RKd1a9mleXtBDy18njrFCCABBxAG
	 0idRncjxHSEw7GKgrB8BUfq2rbbuvEoiq9XsyHCBuny/cD2B9382at8WN5BA+PXQXeQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=chrisdown.name;
	spf=pass smtp.mailfrom=chrisdown.name;
	dkim=pass header.d=chrisdown.name header.i=@chrisdown.name header.a=rsa-sha256 header.s=google header.b=WyNKKpAN;
	arc=none smtp.remote-ip=209.85.215.170
Received: from mail-pg1-f170.google.com (mail-pg1-f170.google.com [209.85.215.170])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B603606A8BC
	for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 20:06:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9B603606A8BC
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=chrisdown.name
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=chrisdown.name
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.a=rsa-sha256 header.s=google header.b=WyNKKpAN
Received: by mail-pg1-f170.google.com with SMTP id 41be03b00d2f7-cdb628232d2so2076434a12.0
        for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 12:06:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google; t=1794686761; x=1795291561; darn=vger.kernel.org;
        h=user-agent:message-id:content-disposition:content-type:mime-version
         :references:in-reply-to:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=L9fh6nGpkdQ3PKE1Pv6VuACg3WWhS00/MicQv00SggM=;
        b=WyNKKpANsG5sdrHWGAt+Y38DvSIGt+WnCUyNYCZoBM4YbSq3wCVAHI95jQ8BFTGgLn
         +vM7af/q0i5zrzjZXXnriwzXN4L/RbeBg/iztvO0eyeIXYNiQp/OYlS5LD9yZqr2gKgm
         1I+5A88e/cV4J0nLZfgp0f7sQwj9jY0Q4quBE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794686761; x=1795291561;
        h=user-agent:message-id:content-disposition:content-type:mime-version
         :references:in-reply-to:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=L9fh6nGpkdQ3PKE1Pv6VuACg3WWhS00/MicQv00SggM=;
        b=dtaOzUiXtZB2W1eIOJUVOMrPRuc0ca2wDX0LF7ZowTQ91wP8uiHOUQ7P1svCXgYrTD
         lnBBiAhQsBTRLOlKZBxqlgPa+G8PDjE6wrjUQV8GUDanr/nCiWk3+qvjIIXL5CZzty2B
         yr+PTPMvfIrHSdejj4KOCdj3LbOqUKBipoWaGjxeHxtuRPI1jKC/VpF4r8mABty0EZDJ
         Y/g26csKDCSAC02kNyiaHJQUSL0PZ1Q0vGqbD8xeqkNRPetUhCWXozf5d8KAtytjLT/r
         vmJnKixpjtVGuutoX1rbBMOJu/zhtww2iqhisYYeUIYonXoVEEUH7ONsHS6LlDl7AFKN
         px1g==
X-Forwarded-Encrypted: i=1; AL+hErHePFPp/ezuIMbzIHjOYmyxb+ZhggU6neRCsfu7A9c6ntsNt4IxhryWCY07juJVjJ5pRVTxVfK4ce8=@vger.kernel.org
X-Gm-Message-State: APuU4Z/n+kpR2nicL7QBuu/jZU/R4TIsXEz9cRNueIaSb6+xvc7mx1lE
	rYjGLaeb9KQBH/qm+HWf520ljT8B+FwFkuFtfLyqNfjqL8OhsABCFgR8YSBVqp4NWPQ=
X-Gm-Gg: AYBFou0qCE5D3pRAXN/xsWJyosuoBwZ9t+1Y/ET7qkMDSa8Po4W9xiMO7UQti9LgZfF
	sZtseBVCuf0yT8UF+XVGfWAXhpBeTwYkymRXwC+36t0YOjJYJ/8niCjc2jVSDkYWe3+4a6GBfnH
	Cb06X0vVjDXs4S/Y7mMLmfaJK1XKhFE0dJ6TMC++T3dlF4o8VMxJxQ7IFZFzr88BPdiY5BhhsaN
	5emvgUjTWLnw7Z4I5iMLoshfwuwsqJ4+MObT72vVlwT6AXf1BjoF6syVQKZsULhJazgVCJoEM0M
	C0LqtiGqMBLF2iHW22tFw9O5BT8PFMd+07GFanbeg19o2RtBSGI3kO2/ycrLx01AqsHhRbxbh5H
	R3yK6A7iN/8aclann6r08IVNJI3OvllnYpci2Bzx2l72rje/9ZWDm1lfSqdJKESVDN0qs+6cbFR
	Ogq40zZyLEsoCQvwvWfO2f6ah6pI+Q4HyAQqaejd3+VveDVm/W0rgMJTfGIGGrYNrb4+B23GUPq
	QBKGQ3ExP3JVdIC7hgA9v+zA1DSk4iV1YBKi9Wgd5bk/PnfGAfUF4H014yW7AMl6OxkLebaHxPf
	s7Vw8b7foULk17l4QD7UnUXhY+PAC6VmgEKP/8R04QbQnyA+MR1RC2GIKEPpVkhDbre+AOSyMDH
	K8AQpgtz0/cN5OyPoTEdwV/mlOwwAfpY+99hQEcjAIbB/5ybr/XtVTEmL92o6SAqUWE7JcUlDus
	CaR75lcIAAkLlbRvD7ZgSzAp4CIUdfwz0T6aDSZbVibgKe/9fTbLscgEBh
X-Received: by 2002:a17:90b:2584:b0:3ac:9f00:3bc7 with SMTP id 98e67ed59e1d1-3b1b0ba61famr5629200a91.33.1794686761104;
        Sat, 14 Nov 2026 12:06:01 -0800 (PST)
Received: from [172.22.0.2] ([64.16.22.130])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3b1b1e9ef15sm5258887a91.0.2026.11.14.12.05.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 14 Nov 2026 12:06:00 -0800 (PST)
Date: Sat, 14 Nov 2026 12:05:57 -0800
From: Chris Down <chris@chrisdown.name>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>,
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-mm@kvack.org, bpf@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org,
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org,
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev,
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC v2 33/42] fs: add file_check_backing()
In-Reply-To: <20261114-work-loop-pseudo-v2-33-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
	<20261114-work-loop-pseudo-v2-33-98639a2286fb@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Message-ID: <20261114120557.4bc1eb6e57218cdc@chrisdown.name>
User-Agent: Mutt/2.4.3 (cc9e3943) (2026-10-09)

Hi Christian,

Christian Brauner writes:
>+	/* Look through stacking filesystems at the inode with the data. */
>+	if (d_real_inode(file->f_path.dentry)->i_sb->s_iflags & SB_I_PSEUDO)
>+		return -EINVAL;

This looks good in general, but what the bots said about O_PATH files
here is real. With FMODE_PATH this is reached for a file that was never
opened, so on overlayfs nothing has been through ovl_open() to look up
the lowerdata of a metacopy file yet. ovl_d_real() then does the lookup
itself, and when that fails it hits the WARN(1) at its end and returns
the overlayfs dentry, so the check passes as well.

Only fuse passes FMODE_PATH, so it takes CAP_SYS_ADMIN to get there, but
it's easy to trigger with that. From a quick test with a metacopy file
whose redirect into a data-only layer points at nothing, registering an
O_PATH fd of it with FUSE_DEV_IOC_BACKING_OPEN gives

     ovl_d_real(/f, 0): real dentry not found
     WARNING: fs/overlayfs/super.c:79 at ovl_d_real+0xc9/0x210
     [...]
      file_check_backing+0x308/0x5e0
      fuse_backing_new+0x219/0x4a0
      fuse_backing_open+0xe8/0x390
      fuse_dev_ioctl+0x53a/0x7d0

and the ioctl still succeeds. A normal open of that file fails with
ENOENT, so nothing could have used it as a backing file anyway, but with
panic_on_warn this is now a panic.

Maybe ovl_d_real() should just stop warning when the lookup fails, now
that it has a caller that isn't trace_uprobe? The check would still pass
for an O_PATH file whose lowerdata couldn't be looked up at that point,
though.

Thanks!

Chris
