Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD559339361
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 06:24:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789367098; cv=none; b=kQ/tw6mokD7ciFnmTI8G+L2Ss5U3Jtm5MaQMPENcFWOpQUT8ZiWgOE7Uu7LOiyVcAhNjKdYO1nAUjedqwdqWqMf68fpYRz5v7FsLdgzxM2a0VhCMnWVrKsdJja5lP7wioDAr9gueLTseFQV4t/8wW3sKoZq+iYSMpzY2QTAze5I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789367098; c=relaxed/simple;
	bh=MNG+gKJhr00lLi/y/d9r3LMRVlwJN4cQZkbNlaW1XCc=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=dKhpSKu37GPmvjanoN1IiawC4N1D5fuez4jey6i/q5D6I35HqhEGs5/yJXVu/m2rG8hWu2mqYwGZ5mmPHKdKg71XzsVRqhZhoG0pJlAtzrUmjL0y+HzfYxrE1NPFw1egYz4zlkO5kJ4JT/0px9/BD+cLiCAcRJeGRaryVgkWmzM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=dcIb6xLG; arc=none smtp.client-ip=209.85.128.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dcIb6xLG"
Received: by mail-wm1-f51.google.com with SMTP id 5b1f17b1804b1-49e6deb520eso20521415e9.0
        for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 23:24:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789367095; x=1789971895; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:autocrypt:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ts6kh5OXf4rLTVWAz3nISNjk6ViIbV+/gfDxcn38oOo=;
        b=dcIb6xLGXfwumGVKLS2lDt6CwsdUx13KDZZ64N4U3uN6TkWwJgw97NNRjxSjNvDFoH
         o5qTxAE9T/4PiXRpSGNb8IgBad4PLSm7ksMlNIrjotOTEREWBGEq/VQeidMLeTLzSjfo
         QlchjjQ/sNXnXMn9qQDm5UaBoTx1ydFlWunOHFsf4qQDLpUxxM4G1UOf2KLP7TdWKqL0
         KUP1z1v6xBuCze5fzkATbeqFzANVXTyZwD/ShSNMtEVC1tB1iOzcaz2GSlM+A5E5f+Nf
         Ns8ZT5ErYXx2JJqNWv9xHohaRT6Y2fi0FjxtFvL8NsKwCGgrG/vjmDP4uG9d4XF2pcnL
         egLQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789367095; x=1789971895;
        h=content-transfer-encoding:content-type:in-reply-to:autocrypt:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ts6kh5OXf4rLTVWAz3nISNjk6ViIbV+/gfDxcn38oOo=;
        b=fDpV5LVHoGTfPlYtzGZLIBvL+6TWFiCtGqn6x8pKftNag9Am+oJMQDBRJnC0g2budr
         zZSf8VfPNbHv+rn2FFrc24DqAV688iCSW6vu7Rux5d2i39S/s0yYKsNEmCoVajl1Ztb1
         kgbu/EKT3WmhXCNnsAkOMqhseawTL5FrcNORyGVW2d4h0JFWB9q0cOwTfApFqQFQkYFz
         rsGmHGZLK07se/e+XPu9KkRg9VQXjOH+LOvosDlsw0zFN5xn7GsWxSvQFhvnK2oQ0YIz
         IsxYl1D3zTcyor1QTMLUl7J0TSXh5vM7zgggCb6J+9Pq53/gjke+4GpG5gZOoqc2Z4Gr
         BGow==
X-Forwarded-Encrypted: i=1; AKwUvBxm3bd9itEx6HKCK2y7F9OcCAQXS3fqpXtPF19r0mZ+wjCe+tBicQ5rgTZTzLwe2g/rOSLudqRgq44=@vger.kernel.org
X-Gm-Message-State: AFuF++m29Ffq3AEkP407AIf+BsbweQsvBKd6t7EoltPVbuzWuIX0vmVQ
	JO3r0Vhn5qSl6Ip6D0YwGimATXLQIN1keo8aANqTuMHe7ReqL8Dqy/JJ
X-Gm-Gg: AYBFou194hFiuH8T/YM3lFFDyn1ElKCAdu0WPOwtaWNNlgaQEEz5ioyxx2I4vDtbU/O
	12ZFoLNcc7dsV9GcFjzlPFxZFyrd6mo686D2/pqzgV0FdlrgvDE1KjxJHjKps8lxMKuURxyVgvr
	4/b3JEOcq3xHy8n9U6xRtEDxOxqATuGT61MezFqMZQbaWutj6i5lKJliQl8i/hMFkhbacmTl7wP
	8ZdSr3g8gY4JcmqMxJi5KP8t6ZehvvYTCFE6mPbPWUkNNOQXZ6hZ+rltaETNziG7b5DnN5LaHVy
	rbcBOmKtde9yOw6hlU2338IPPRWHNTTZRejXqcjrpSXht8AtFk2ytWWAEa+6snf6ZY4MZP+wU6v
	9IpSIqkMIwjLA/Od0Xo1QBPmx94kHxZyZ7aGV/0GeLt2bsk7Gx30XQpf6lhF+e7qMD01I63hh8Z
	baxwrM7ZQ7IGnyyZb70T4mNIzF72P0qempva+CQyE0MnvBNgGMLFqpTw5Ajwx0P/aRDHR87C+Z/
	XBtzOfxxWOBGT6wj+XJu6GRchSP9TljbyRq/xx6esAnHWWkFfqj6XSqi1t2o9MtIUXH24r7iA==
X-Received: by 2002:a05:600c:3593:b0:499:8704:242c with SMTP id 5b1f17b1804b1-49e7a5eda7dmr12242155e9.0.1789367094507;
        Sun, 13 Sep 2026 23:24:54 -0700 (PDT)
Received: from ?IPV6:2001:778:e27f:a20:8aa4:c2ff:fe18:16a3? ([2001:778:e27f:a20:8aa4:c2ff:fe18:16a3])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-49db038401fsm446512345e9.13.2026.09.13.23.24.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 13 Sep 2026 23:24:53 -0700 (PDT)
Message-ID: <ef045e0b-8700-42c4-8ec6-a13cbe8d0940@gmail.com>
Date: Mon, 14 Sep 2026 09:24:52 +0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH nfs-utils v2 00/10] mountd: bugfixes for up/downcall
 interfaces
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org,
 Steve Dickson <steved@redhat.com>
References: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
Content-Language: en-US, lt-LT
From: =?UTF-8?Q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Autocrypt: addr=grawity@gmail.com; keydata=
 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
 aETxZy4lQ+jpsbG/q9fvS/sAZA==
In-Reply-To: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 11/09/2026 19.25, Jeff Layton wrote:
> Mantas reported a problem with his configuration that was using crossmnt
> and autofs to export a number of btrfs filesystems. Some analysis with
> Claude also uncovered a few other bugs. This version also fixes a
> number of problems that Sashiko flagged. Some of them were preexisting
> but seemed like good things to fix.
>
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
> Changes in v2:
> - Retry instead of caching a negative when the failure may be transient:
>    kernel errno, statfs, fsidd, and an undelivered negative fallback
> - Drop a deferred request once it has been answered
> - Bound the junction path copied into exportent.e_path (preexisting)
> - Give each worker its own netlink command socket (preexisting)
> - Bound the retry queues (preexisting)
> - Link to v1: https://lore.kernel.org/r/20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org
>
> ---
> Jeff Layton (10):
>        mountd: factor out the per-path export attribute computation
>        mountd: handle unmountable paths and junctions in the netlink downcall
>        mountd: answer requests the kernel rejects on the netlink downcall
>        mountd: don't leak the parent export's fsid onto crossmnt submounts
>        mountd: retry unresolvable fsid lookups on the netlink downcall
>        mountd: bound the junction path before copying it into e_path
>        mountd: give each worker its own netlink command socket
>        mountd: retry export attributes that fail to resolve for a passing reason
>        mountd: drop a deferred fsid lookup once it has been answered
>        mountd: bound the retry queues
>
>   support/export/cache.c | 1331 +++++++++++++++++++++++++++++++++++++-----------
>   1 file changed, 1026 insertions(+), 305 deletions(-)
> ---
> base-commit: 630393e9c73667b3fda6a7507cb5171ec0ec38dc
> change-id: 20260908-nl-crossmnt-85584b71c721

Hi,

I finally got around to building the v2 branch, so now I've tested both 
v1 and v2 and it all seems to work well so far. It successfully exports 
ext4, btrfs, and tmpfs sub-mounts via crossmnt.

Since I'm using a blanket export, rpc.mount does log three errors per 
unsupported sub-mount it encounters (proc, sys, autofsd-based /net) the 
first time it is contacted, which I suppose could be less verbose, for 
implicit sub-mount exports at least. But since my usage of exporting the 
whole of "/" (with crossmnt at that) is probably generally rare anyway, 
it is not a problem, I'll just filter them from my syslog errors monitoring.

(Is the -7 supposed to be E2BIG? If so, that seems a little odd in this 
context, but I don't know netlink well.)

-
rpc.mountd: Version 2.9.2 starting
rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
rpc.mountd: Cannot export /sys, possibly unsupported filesystem or fsid= 
required
rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
rpc.mountd: Cannot export /proc, possibly unsupported filesystem or 
fsid= required
rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
rpc.mountd: Cannot export /n, possibly unsupported filesystem or fsid= 
required
rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
rpc.mountd: cache_nl_set_reqs: SET_REQS failed: -7
rpc.mountd: Cannot export /net, possibly unsupported filesystem or fsid= 
required
-

