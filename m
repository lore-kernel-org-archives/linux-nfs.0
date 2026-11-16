Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794830416;
	b=3pOXtaiohbWFqqfdolMaua0GHTdqpjYiER/x4GRoQ0Ml+ilwTmhfjgJpORKPiHRvWdr1
	 5CGEDJfKsGxzRLKNkv2Tmy8AMNN7sIJGw/+3fynD5cnoQBNTBEld002sEU7UDiKEnONXc
	 WoOiZZknZ7HtGce9lNYv2ipGlc4hBzzm+7g3MmrRDMapSWvzkKddElBKC1EDUArZ24yry
	 q/SDED+Cmbj2kmuIJ9tG99FQmBjzg9KVva2FRKcnAhfpUHP9Pm1pYI6dmExBXO9HpQQoL
	 mqnw17nZElMyKZxgaZVOkEOgPPdI5DRbZLr3VvQZiOoYuJvyP9YjpuHW9pLt/aQ3eRw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794830416;
	h=Received:DKIM-Signature:Content-Type:MIME-Version:Message-Id:
	 In-Reply-To:References:Subject:From:To:Cc:Date;
	bh=gm216H5g8yPIS0hPFinwHy6mVVrhGulY+53WmPc6rN0=;
	b=j4HKID0c1b6DHjI+QzTUoWCC53iSNtlphJERwcOxRR79gncah6YO7UDXctyD5LmnONtW
	 NeP8gadthTSouZ0thJFcxa+Oloj4qV5oZxxBzP+oJIZEk9DiLIUtDMn+uvaBNrRTftygY
	 V8Y1lgzBSgrHenqYjOpeeh/pQEwTrqq2DmqsBtSk6PrfaxZ3GXcguvcvJjZS/IG289wMd
	 iAuWJ/7jHgaXAlWDM1AZiG8JU/rpsAbb84MthfwH/sDyrOrtX89ovqqV9xQ9wbHfGRne8
	 /1NRXTi9nsrfI7ftQ3QtW9hxYt5JmgJQotz7ClizyoAzCOUcM1jTs+TnKOh0FTfOT6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hnZy2toz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA70F606A329;
	Mon, 16 Nov 2026 12:00:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hnZy2toz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A04FD1F000C4;
	Mon, 16 Nov 2026 12:00:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794830416;
	bh=gm216H5g8yPIS0hPFinwHy6mVVrhGulY+53WmPc6rN0=;
	h=In-Reply-To:References:Subject:From:To:Cc:Date;
	b=hnZy2tozWrqXpWLl+o5+qP9GJB7maIdtKambAdlwVeTUYSiv1MRn2/JyDHmnbWh9z
	 9WDgZMPWzEFJyZJLu9/wsHqC4IslySPV7y2m6l1l6Pr8NgVibCFxmyKogUiorVMDDs
	 oSUXCyKp79VfkW+5dB+6SUIEC6UIXRKMD5lFDe0TpDOweWXRS/8hWTozfLGQIQW1P3
	 PpqAtsruCxsT/ZGQgn4L2ujm+ycdGpwnf6KZ9ATazwCNfMJ3LvW1RLCzk2tHDAf+iS
	 l45B1JKOto718M05wX+oTkpRye0x56eTuMcf1pJlfnKjWSS9tECKCjPVeZoo9oaT6o
	 l+RQ5GFUaEe7w==
Content-Type: multipart/mixed; boundary="===============5220694122544816000=="
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Message-Id: <cb28f09c85a473a23f14c9bd6ef135950197c9fbf966c1f7055d791977d29286@mail.kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-38-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-38-8cbbea1cf34f@kernel.org>
Subject: Re: [PATCH RFC v3 38/44] nvmet: refuse files on pseudo filesystems as namespace backing files
From: bot+bpf-ci@kernel.org
To: brauner@kernel.org,linux-fsdevel@vger.kernel.org
Cc: jannh@google.com,mason@kernel.org,josef@toxicpanda.com,hch@lst.de,linux-block@vger.kernel.org,linux-kernel@vger.kernel.org,linux-nvme@lists.infradead.org,viro@zeniv.linux.org.uk,jack@suse.cz,linux-scsi@vger.kernel.org,target-devel@vger.kernel.org,driver-core@lists.linux.dev,linux-mm@kvack.org,bpf@vger.kernel.org,linux-security-module@vger.kernel.org,selinux@vger.kernel.org,apparmor@lists.ubuntu.com,linux-nfs@vger.kernel.org,netdev@vger.kernel.org,fuse-devel@lists.linux.dev,linux-efi@vger.kernel.org,xen-devel@lists.xenproject.org,ocfs2-devel@lists.linux.dev,linux-s390@vger.kernel.org,linuxppc-dev@lists.ozlabs.org,linux-usb@vger.kernel.org,amir73il@gmail.com,linux-erofs@lists.ozlabs.org,linux-kselftest@vger.kernel.org,brauner@kernel.org,chris@chrisdown.name,ast@kernel.org,andrii@kernel.org,daniel@iogearbox.net,martin.lau@kernel.org,eddyz87@gmail.com,yonghong.song@linux.dev,mason@kernel.org,ihor.solodrai@linux.dev
Date: Mon, 16 Nov 2026 12:00:14 +0000 (UTC)

--===============5220694122544816000==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

> nvmet: refuse files on pseudo filesystems as namespace backing files

TL;DR: The series may not build: file_check_backing() in fs/read_write.c calls
d_real_data_inode(), which seems undefined anywhere in the tree, so a
prerequisite patch may be missing.

> diff --git a/drivers/nvme/target/io-cmd-file.c b/drivers/nvme/target/io-cmd-file.c
> --- a/drivers/nvme/target/io-cmd-file.c
> +++ b/drivers/nvme/target/io-cmd-file.c
> @@ -47,10 +47,9 @@ int nvmet_file_ns_enable(struct nvmet_ns *ns)
>  		return ret;
>  	}
>  
> -	if (!ns->file->f_op->read_iter || !ns->file->f_op->write_iter) {
> -		ret = -EINVAL;
> +	ret = file_check_backing(ns->file, FMODE_READ | FMODE_WRITE, S_IFBLK);
> +	if (ret)
>  		goto err;
> -	}

Can this be built?  nvmet_file_ns_enable() now depends on
file_check_backing() from f66083ed0be9, which does:

fs/read_write.c:file_check_backing() {
    ...
	/* Look through stacking filesystems at the inode with the data. */
	real_inode = d_real_data_inode(file->f_path.dentry);
	if (IS_ERR(real_inode))
    ...
}

d_real_data_inode() is not defined or declared anywhere in the tree, and
no commit up to the end of the series adds it.  Only d_real_inode() exists
in include/linux/dcache.h, so fs/read_write.c looks like it fails with an
implicit function declaration.

If d_real_inode() was intended, it does d_inode(d_real(...)) without any
ERR_PTR handling, so the IS_ERR() check would never trigger the error path
the f66083ed0be9 commit message describes.

Is a prerequisite patch adding d_real_data_inode() missing from the series?


---
AI reviewed your patch. Please fix the bug or email reply why it's not a bug.
See: https://github.com/kernel-patches/vmtest/blob/master/ci/claude/README.md

CI run summary: https://github.com/kernel-patches/bpf/actions/runs/43858134663
--===============5220694122544816000==--
