Received: from mail-ot1-f46.google.com (mail-ot1-f46.google.com [209.85.210.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 750654E73A8
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 15:43:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792165425; cv=none; b=OgCmJXXOb8OQ9u2LCvd0uuyTHJ/+Is6+c1cT4D6IwfV9nTWRj8sZtD0zaxLgiAlmPaih6Xx9mm+rF5MsYau782U8tn9TlUCwU/S2fKW3oXGKLswPva5W8AqY9rXGL9i84JX7+loJeFTa95i7bmOAHM1SQhGN/kuFnetuseveNGA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792165425; c=relaxed/simple;
	bh=W3IbJgKoDqrD/rDFntIL2y19bm17P+UUtb6LKK9vtXQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=uKgTClzJyMsA7r8xaaflBmu/gmUWsw70oTIADuJSOe7/iM0mzpxFwo0j4I28fNzf+G/UrXTaZKxuIwdUHooT+Y3YKThP6soctzCxojLiCba6fRzGCDv5tc6o1bbdwFWHXhKdT4fqLxRl6/cp+znkqXbbGPZXnUOCuAUzjE7ypD0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=niKgcoEB; arc=none smtp.client-ip=209.85.210.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="niKgcoEB"
Received: by mail-ot1-f46.google.com with SMTP id 46e09a7af769-843ea301d60so309708a34.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 08:43:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792165423; x=1792770223; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=3tFFFiMwu3rBvdKgwC5eml9Ot1DFSy/iaQYkSX+cyDU=;
        b=niKgcoEBxFo7wvXkQvghQuGJyzd9G03NuXu5Iy2k121i407zUWnPvMC0zx9xaeTIWf
         vU8fT2C7xjLlpFWOtGGg1XbktoKO1TT7XHU5PXuxJA0suwnQVNnzYy9l9sJtZNezDp7+
         708nsCg1+Kr8VwVL3acOikWz1HPfkQjJ1C8yGicOb73Za2iQEZPaTwkOaiAuj10fzIEF
         fGi2g0szr0VoxgQGMOkhM5kkodW8DAlvIKtPSsEJ7wKOeukLzXKT57rtD8uTuILSLvtk
         EJox60UmW7zFeG+9mzyupF1YAoNOucMkAgDoz3eUMJiL2n/zNXyqvmNBGa8Vvsz8ZnYI
         TV9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792165423; x=1792770223;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=3tFFFiMwu3rBvdKgwC5eml9Ot1DFSy/iaQYkSX+cyDU=;
        b=c+nSOSj4WbMBtZr0ykLOvtRyzCymI45lg8o6yyEN3sJDk1YxQd9rnqcmTmU8sDCX1o
         yOtSyRTqDHGpE/hhv7QRshSj+YW52HryxOlq1/hgC5lbGEapil24vkwT7H2RSQHoEJMx
         WYoycwfFiGhNDLtuwAWsR1OddQLKqM3bciWplyqXbL2bVJkCN8qBdnVSru1fpSriqSl9
         8jkmLFIlQSPe0E5RkQ72q9BWGMmZ5nCK6HyKzfs9Nr2c/TWaKH9E+5v0rva2QZ/bWaLA
         EOc7156nRRDBmTzy43ZvwdqdDN+dQ5EQ6NtKeMuA/S2TiqoaYt9F5rO9YcXYDn6vXmHx
         Z0HA==
X-Forwarded-Encrypted: i=1; AKwUvByhn/EwvloyH5f9V3A2PtVnV5HpIIH1UEJWswJf63jn2t7/rwiKdHJBCRhbwsX2xb2qpvdqBtQYBME=@vger.kernel.org
X-Gm-Message-State: AFq9FYKhsDxDMId+g1/HTAQDFVcRQ0kLxdLoF5kffZGaK7tQG9q0K/h6
	MSxazP9Zzj4pXqq7D1LXHLTUs4U5GkBcM+sJpcipt9k+Gh3pOik3BuLefSDk++IcmNYIrkBB15d
	gLRPu
X-Gm-Gg: AYBFou1XrvP8oIUk/PgeDDd9m7EBOhyeAmXbdAKFjyqd3nkWp7BLtsAODgygVQuT3/h
	z+dEyYCFZDjG2Rvhyi8E6tHzHXiVSCnbYNKxqIywuCPWxYKRmR5N+jkfsZbvBTknxWDWBTKx+Gq
	dccfFhZhHfMsX2RMErls+ZvSSix5JMS6uaeMQ9dYDszf5aFXZDPjQhqtXki4Ih7ggFPQWJfjL/R
	gWkdUd6HdQuU9nc3VXgRtt4/wSytVh8s39LyMTUG5KMDhAd2ess83zcJ4RaqSWPfmJQLCwsSRgM
	lRpm7SHnczJH5gEW4ZPfJTdSe8i3Q+20hIVhsZgGZYRlH892VHyrrIeR/b33kQQqtFHYbX+HDg4
	Wh7JneFpjbxgO71cIPFugNqR+tEL47UrNbUAFq4zDLeVEFHj0S09qYZS0SSDCwluCJg+eHD0lNX
	Xlw8W6Qu7ID4w2/hZAtjO3B0dJrzDRIezehqPs1mXjLQVfGZvfDylRfZnb0iadTlNMa14gnZFV4
	8Y0S+HRdXforWWwyg==
X-Received: by 2002:a05:6830:25d2:b0:82a:bf47:a080 with SMTP id 46e09a7af769-8309815d97fmr20400336a34.27.1792165423175;
        Fri, 16 Oct 2026 08:43:43 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-842a6e12e06sm2040750a34.22.2026.10.16.08.43.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 08:43:42 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils 6/7] mountd/exportd: always give pseudo-root
 directories a path-based uuid
Date: Fri, 16 Oct 2026 11:43:41 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <1322CC7B-28BF-471B-BE56-7BB428CAF589@hammerspace.com>
In-Reply-To: <20261016-netlink-noproc-v1-6-42791f4b6eb5@kernel.org>
References: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
 <20261016-netlink-noproc-v1-6-42791f4b6eb5@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 16 Oct 2026, at 10:15, Jeff Layton wrote:

> c5528f40f9db ("Fix NFSv4 export of tmpfs filesystems") made
> v4root_create() generate a uuid from the path only when export_test()
> says the directory cannot be exported without one, leaving others on
> the filesystem's own uuid. In practice export_test() fails nearly every
> time, so the path-based uuid is what pseudo-root directories get:
>
> - export_test() needs the "-test-client-" auth_domain, which only lives
>   as long as an ip_map entry that references it.
> - With netlink, nothing creates that entry: exportfs's can_test()
>   returns before writing it. The kernel answers ENOENT.
> - With /proc, can_test() creates it, but exportfs's own cache_flush()
>   frees it before mountd rebuilds the pseudo-root.
>
> The fs uuid is only used when mountd rebuilds the pseudo-root during
> the brief window in an exportfs run on a live server, and then that
> directory's filehandle differs from every other time.
>
> Always use the path-based uuid below "/". That keeps what servers have
> done since c5528f40f9db, closes that window, and drops a write to
> /proc/net/rpc/nfsd.export/channel that ran even with netlink.
>
> Also keep uuid_s in scope until export_create() has used it; eep.e_uuid
> pointed at it after the block that declared it had ended.

Oh yeah, nice catch.  This change almost deserves its own Fixes: patch.

Ben
