Received: from mail-ej2-f12.google.com (mail-ej2-f12.google.com [74.125.228.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF6392EC0A4
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 09:24:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789464282; cv=none; b=KrqOSyvcivPI8+ZbHMQO/2Av2bbLp8KFTVi9I1Bm522uJMZSj7IuwYx1AEYcFd60+8XQfts71Hn/XGdCQrkD2DtAVudTpYGUozBTvxUU6isDaczG/K8R5r8W8TCek+yToLkeXa6nQrjKzQgYLatkPb013Zykb4Oe4jw/44x33+4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789464282; c=relaxed/simple;
	bh=LeWsE4Ym8dcNFdY6OjjewfNmmzj98HHc/aocsOyIln0=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=UgU8HwaF/6W/xxjO5LA3Q+d0+ejMjKdleEo39yiqcCf7LSYZNYo3pMO4Wl8mUA67Gt5Ip8SWdqG9698WA1bNX+cnBQ98rg/Ft+h8qSloW+d4LDZkKeYjVHDUj+KiEjc6KG4UNwzGLtgq75m0PQGL+chHBaNi8WtTWlmn/dYApIw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ecC7zqQp; arc=none smtp.client-ip=74.125.228.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ecC7zqQp"
Received: by mail-ej2-f12.google.com with SMTP id a640c23a62f3a-c254f8694aeso202013966b.0
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 02:24:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789464279; x=1790069079; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:autocrypt:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=rWZ4/DK9pUInU6dyI/H/f7xQ7BIPcjohphBT1g9rFnY=;
        b=ecC7zqQpeJUvDokdH8qTfFa+3k3QMcr6ypTrv+vO75WcIVYtQUPCZ7vgOz69KD0BfS
         4rN3IMVuXn3buxgvz+LwfFhxePG+DasQjB5z3z629cNtdAH4ds9KAm/1tHyAl/LuF/5v
         R5QqPSm74V34sawJMkqbOixttpv6YIy+xhd2wbyL1mHC5q9hrrX8JrvctkXAgABh0sgl
         zXvFQaRO8cmHXSzMOWJiW2yGPtZeh03qpxZFVI7AKpF+OBIBnD4Kq5QH2fQ+42ImnYtm
         Q7mNuSB94+uRJeoEqszf8itfB1FWPHKDFCZt6H2EjPjs9lMsXfggY7Yxk/LykfY/pKhF
         ytGA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789464279; x=1790069079;
        h=content-transfer-encoding:content-type:in-reply-to:autocrypt:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=rWZ4/DK9pUInU6dyI/H/f7xQ7BIPcjohphBT1g9rFnY=;
        b=EFJj3dk0c3eeltxIPQ4Ufs7dijV6CWbUn/U/D8MFpVDLdMJyVwagt9dkojaU7XR7SO
         4Yqbc6Zx+olGCGjxztJAB99kGTpdJcJKzizQcD3d4wlxZDWES/Cn7ssSvTE78RBp4gDl
         Yni7wHlTxwqoFG3oqPmhyx5eRJeyGwYZLJOYHM7N+jGgnBtqMU15YM0MmI5Viy0NrvPR
         jGWijhR3ZCKQOhIBGNI8/F/uzfmZYOKLtNNySXR1610akVzGOR9x6rdFBTHYai9SG2Gk
         pBFmasiXaKoNYJh7SczRi6DNEzNgfpmb01f8+Q2ipzuuB40xaCryfWpMYzXn5cnbdWIL
         KBBQ==
X-Forwarded-Encrypted: i=1; AKwUvBxT6KDuhWbNSVR6cdLIEHel3cdIswSAShj6sm6MDMoyRB5G49QdnzTz0cIKgqk5BBoZX/DKAkPfQdU=@vger.kernel.org
X-Gm-Message-State: AFuF++mT3EITARteW4cymYCjOo48u9aelAhJra1j09zUx+WQGxKYQ+0U
	UARGVt0xS5e8/IDocOYSxMzGN9dqi7fOKk+MeabUMFswwsa8F+QAVdkcTIVe7tza
X-Gm-Gg: AYBFou2keoG8wvNioFbSQm4GWLvyOEBmvwCrmsX/kgp4/0FEwK/H+7IZgyZEd3Ls7bK
	zZDGxHKxICraZfv1nx2U0edWEVcNZv8As5aenRTUc5Kv3EgOahFL+839ETX41R2buiCh1hIhlNl
	WxUYlSrpj4R38710ptmmfv7zvN1VePIdi0AbY7vmjJecvH0p+8todwrZCyYXGB/nlB+4wEOBUsu
	dqFTYqOGXFdhFTfu23GbQdhqfguvSF9lWkV5IlcqdkWfhCNI+X78lxObFd9wbwlQjn/v6XxjLJy
	/PamRlD4YXuSkHBbPKSHB/yi35kePrq5XdLFL2tWPFF2uOYGqsIfaorf/OWlYeKIVnBlhzmbuz6
	igwRmEubVblDUvwbOkzHVsBFRguFJfHK5W8GPke1M5cF7yX1jnZlyhNq3KvDUVBX0ExP/DyJdl9
	AXTm1ZH/JVBXmhzsTThindc29ZyeFzKoqwFXGgQ+uLHmeawg6QwXpDi+toYjVv6SJlcWB2g4DAK
	hC3zyJtu9iJrTsiEcCU+TeTPJYe8Y6qjbcSzj4Cu5iCCBgouXe6000YDJm7ds/Vo5wxdpnI0Q==
X-Received: by 2002:a17:907:6d17:b0:c24:6382:2648 with SMTP id a640c23a62f3a-c29c8914764mr234816666b.5.1789464278765;
        Tue, 15 Sep 2026 02:24:38 -0700 (PDT)
Received: from ?IPV6:2001:778:e27f:a20:8aa4:c2ff:fe18:16a3? ([2001:778:e27f:a20:8aa4:c2ff:fe18:16a3])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c296598e8b0sm541419366b.0.2026.09.15.02.24.37
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 15 Sep 2026 02:24:38 -0700 (PDT)
Message-ID: <fc05f07a-9f88-48b7-8b2a-40c44e886985@gmail.com>
Date: Tue, 15 Sep 2026 12:24:36 +0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH nfs-utils v3 00/11] mountd: bugfixes for up/downcall
 interfaces
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org,
 Steve Dickson <steved@redhat.com>
References: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
Content-Language: en-US, lt-LT
From: =?UTF-8?Q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Autocrypt: addr=grawity@gmail.com; keydata=
 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
 aETxZy4lQ+jpsbG/q9fvS/sAZA==
In-Reply-To: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 14/09/2026 16.14, Jeff Layton wrote:
> The main difference in this version is some cleanup to the warning
> messages, so that we don't warn about internal events. Mantas, if you're
> able to test this version too, that would be great.
>
> Mantas reported a problem with his configuration that was using crossmnt
> and autofs to export a number of btrfs filesystems. Some analysis with
> Claude also uncovered a few other bugs. This version also fixes a
> number of problems that Sashiko flagged. Some of them were preexisting
> but seemed like good things to fix.
>
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
> Changes in v3:
> - Stop warning twice per unexportable path
> - Keep a warning for the ip_map and unix_gid answers, which have no fallback
> - Don't warn about a submount nobody asked to export
> - Quieten the same message on the pipefs downcall (preexisting)
> - Link to v2: https://lore.kernel.org/r/20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org
>
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
> Jeff Layton (11):
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
>        mountd: don't warn about pipefs submounts nobody asked to export
>
>   support/export/cache.c | 1391 +++++++++++++++++++++++++++++++++++++-----------
>   1 file changed, 1084 insertions(+), 307 deletions(-)
> ---
> base-commit: 630393e9c73667b3fda6a7507cb5171ec0ec38dc
> change-id: 20260908-nl-crossmnt-85584b71c721
>
> Best regards,

I tested the v3 now, and it seems to be working well.


