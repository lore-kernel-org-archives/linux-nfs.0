Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793037537;
	b=YwwYMTiK0ULtroH0/KPIe0YrEST2tal+hLJ5MMmrvYEoFepoTW62pgvZjEzg8rUeeSYf
	 lW9QlZIUN8nOrqGspc912T/XAFHFlvAxmWzXVFntSEw3rgOF0Si3Bjdqv2FOkw75nn6ds
	 AUFANJWCRC2VVDs4Jok9bRb6VXwyAtLgbmtTMIU3wfTgk9zcCu47Dxi7EwabcHZTXVWev
	 D/W7cAtZBn1oAw1bxfaHPr1rZZpqKk/3vrcwgCuPM596PCc7wi5NVxUuoBZxzf2ZKVCCF
	 TJTnlNV+HYfM/djdQyuEVHFlxFyly1pbis9rPKFojkJa9JzS2shyKt4fbIZjBKjDHSw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793037537;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=z97LGSe7E0X/qE2ZQjilW33CRFTQWIItl3veF3leiBU=;
	b=cIIKFaFZs4YulYSZbKYVtBUF5u1NVD08OI6jXTx8gc718KhQGiH/Aqmm9RY0o4ILCnGh
	 HgQd3sLX7lcFDBjraqJKI7pLGfm9ZRA3qa+cScaJrnvK4Qk8nqrw/ZV/cvK8XRI+08U48
	 hAHp5JiTz+37ivbzmWmEoaLUvA3NcLw6qu9xwem1+HbpepRtxjMiodmbIcmHARBCiXFHy
	 yxueFl43DgbHv3GAthN1Ia/anJJlt0h75NDOBBTu3MyJ4XyLxaVWutROM9kFbNbr6EHlr
	 CC375BZHPtGv2XeMTHwa40sS6W4JHwEa+tQ2DM7dn49hs7aZ2HHPvt8rz+UqnfKxtew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B1umS55o;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96947606A31D
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 17:58:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B1umS55o
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EFABF1F01828;
	Mon, 26 Oct 2026 17:58:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793037536;
	bh=z97LGSe7E0X/qE2ZQjilW33CRFTQWIItl3veF3leiBU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=B1umS55oNJGONGszAtGerfWeoi6NW83Uoc2a3Cyt5o7qt1dsRrgKlcG4yufpLOD/t
	 y3mp5eiROTQq4lGA736XvmMmlbIn5Be1QmiZdBVxozyNH4u5NFbcwK79rMFBl7o4aa
	 Ko6KwfI5u/8RC5d20lVnHOTMo00fHCzDntx+gdOMfqbk5NdIQpYj7anPtjXYbIEMXD
	 Y+HQ2vQPzckHuzd21iB0VzQMmSPxMfFJar/mlW9B1Ke4qbiX/QDkXz0RNdN02wZTv5
	 QzS4AFptdGeNcCzxqbhyMFA+KWGDaQQ0pz/z9N/hmzAfPAqspglWhOVLicoI+C9Lhi
	 9kG1Csc1nzjUA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 405F7F40066;
	Mon, 26 Oct 2026 13:58:55 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Mon, 26 Oct 2026 13:58:55 -0400
X-ME-Sender: <xms:35Tfar5xFJjYW3L6BVXYxE8Kup5pAT2BD9SHK9w489d2w-U5skAPEw>
    <xme:35Tfarv1m5nthkBqGlk3uKrdmqdaoWjJZN9G67LgHnzjb7Imt1yEjc7tWvg03geJd
    GURqtWw8gpwXOgyuunv2fMJYEQcydQMK0pGNnaupILFFYhcZP_pvmk>
X-ME-Proxy-Cause: dmFkZTGoBcK5Rh/7FPMiKXwbH685WvGHiFRvrhdP98Fq5zQAU/+ip/YJZCmA0erAxz4VZb
    QvRd7ofmV4mvI9oHTpQBwqKhOPRkQqxMCVa3D4nvS661INUptTTT3cRFjA4sQeASB8ZhYb
    wwNkzoJtD3PzsyTL0AOgUoHJq7o8vHq3JesC8o3CqN/YhyzNstd0lQOlJCc5hNNeiMbXt9
    tven5+wMzDZ77Y1r5AyLgzL0VqaUXaNlHQPvwWHTcy3zeyeWR9O7y/Lwu91gXAuBDP0QwT
    LjePon/LYLxJlZQm+iCpSkrVpncginlaOzgkp6nCIsXaybj0h7/vq7vN5iaoALxoaq9tI9
    x/HZPy1GMWofqU7LVKbuCkVDHnh9DBA5ezm0dYIBDMIyMxfshIQgDou93TyN/dvoKuW2cD
    8rCivS8FoamTrCXnnhbn6hxO+XUbLkK5T++Np6eS662akTZIe+irD1Oh5XqodfUTg1AFeB
    KymeCmbWqIhfE8N033sNFWlEAx2PnC5Wfy4FEncR4pETSBsKPcyixlpMSoQ5jGsbRLpS5+
    Q2UYD3e6QsbvMKWpmGy9cVQARK1uQD3A8cbPqyEze1+zSOJ0RNEQMvCrG/+fOiVVkDTXiO
    OU5go76hcffLeqhssCC3NYheZdZLLi3G9pMs+I/3PJl3J/Xl7nKVMsLWMrVw
X-ME-Proxy: <xmx:35TfavJmw-utBC1JzR7now4l-o8yUnBusi449jmbA4nK1QdvF7sk_A>
    <xmx:35Tfajn3acV9CHZQAlgDUxcJrYHVOpUBVDYJyEw2YeG_FvL77IXdtw>
    <xmx:35TfaoZ1zmHLYdVQgAGNApeBf4Dy9VA8QrsF0tVwt8QfIOVxkGFn3g>
    <xmx:35Tfav9U0iUXKFXoydCp8ENmBESRdQ88-hdWZUemL7hvAQsEBDklSw>
    <xmx:35TfanaDpQPDvg7EBRtcLeJhhhtenDJl5IN69phTGK-YUoJ06MpUhuKT>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 17473B6006E; Mon, 26 Oct 2026 13:58:55 -0400 (EDT)
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
X-ThreadId: AnEwjzhednbR
Date: Mon, 26 Oct 2026 10:58:34 -0700
From: "Anna Schumaker" <anna@kernel.org>
To: "Christian Brauner" <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
 "Alexander Viro" <viro@zeniv.linux.org.uk>, "Jan Kara" <jack@suse.cz>,
 "Aleksa Sarai" <cyphar@cyphar.com>, "Chris Mason" <mason@kernel.org>
Message-Id: <f2380833-fc48-44dd-b0e1-c28cadce6e1f@app.fastmail.com>
In-Reply-To: <20261024-work-procfs-fixes-v1-5-46b03c3a8fac@kernel.org>
References: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
 <20261024-work-procfs-fixes-v1-5-46b03c3a8fac@kernel.org>
Subject: Re: [PATCH 5/7] nfs: create the /proc/fs/nfsfs links with proc_self_symlink()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sat, Oct 24, 2026, at 3:38 AM, Christian Brauner wrote:
> /proc/fs/nfsfs/servers and /proc/fs/nfsfs/volumes resolve through
> /proc/net into /proc/self/net. Create them with proc_self_symlink() so
> nothing can be mounted on the links themselves.

Looks good to me.

Acked-by: Anna Schumaker <anna.schumaker@hammerspace.com>

>
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
>  fs/nfs/client.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 60386330aeec..97e363ac7a3e 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1528,11 +1528,11 @@ int __init nfs_fs_proc_init(void)
>  		goto error_0;
> 
>  	/* a file of servers with which we're dealing */
> -	if (!proc_symlink("fs/nfsfs/servers", NULL, "../../net/nfsfs/servers"))
> +	if (!proc_self_symlink("fs/nfsfs/servers", NULL, "../../net/nfsfs/servers"))
>  		goto error_1;
> 
>  	/* a file of volumes that we have mounted */
> -	if (!proc_symlink("fs/nfsfs/volumes", NULL, "../../net/nfsfs/volumes"))
> +	if (!proc_self_symlink("fs/nfsfs/volumes", NULL, "../../net/nfsfs/volumes"))
>  		goto error_1;
> 
>  	return 0;
>
> -- 
> 2.53.0
