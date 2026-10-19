Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.210.49
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792432213;
	b=C/6o2eBFtIICsEuxqbwz2TIwPF/CKIqlFJmRNbI+QfwdTp3DIeasQyo8zFBxOTOCa2Yt
	 Qr+wRn0GNuM1nqxm5bkS+lFcnO27WENUCQ9244sNbPZ8u9tbve1gcNCZcb7JOPLjtUf0f
	 tAdEMyFTi0GJ0VpRNwDiKRrigAtkLlKngnY9CobOnTj+6RyI8JRzFZgl2hCdFbXpukcMU
	 6DxQjWQpx4/ueR+WXDckkrWzK7ZCqpzHlBlStfJJecZB4+w3QJNgnaaKwObRxq+6YNj86
	 m81QUEdhLhJMtzrgdkeWtTTfK8FLwTyrdnqzlDglNvXCGR+4EJNOIFd6pYFnzoetsXw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792432213;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:References:
	 In-Reply-To:From:Date:X-Gm-Features:Message-ID:Subject:To:
	 Content-Type;
	bh=SMhnz8nmfeCa3vbVXb+2Iln/tpnO8JT5gUr+zaobt+Q=;
	b=PTpAP5nis+GXC9Y5FRg3bvlXYMttnxdQetc96Ew1pPo9RjQBXu3ghqO/BixYRGQezMhK
	 CNvEhp1bszWn/vh/jPhTpHIbeoWsruKq+ESWnuV9f05VuAthfYKkzhGwWBVz/nnEIIM/d
	 ssgqnAkM8n/ytJZ8om+fn+MKFfCxZH+RHtsVdtFuhTC6v3u9Ol5jChovu5H5mSpqIeDGC
	 O+1CCx1kKZsJRz4mKA8j47ZgMQDsNNHU3Sd6OLno0aAfpQu7wtpMBbuqfaLV9ZuJfp7Lp
	 HcwfUAEuc5N/VyZ3Cfzz68aYq/R+5/IsnxRXjZ8U9N0qVsSaS9zQ4lDNrB1lAR2k7Vg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=QDrr5W3E;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.210.49
Received: from mail-ot1-f49.google.com (mail-ot1-f49.google.com [209.85.210.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE478606A319
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 17:50:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DE478606A319
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=QDrr5W3E
Received: by mail-ot1-f49.google.com with SMTP id 46e09a7af769-7f48c750afcso1205381a34.0
        for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 10:50:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792432212; cv=none;
        d=google.com; s=arc-20260327;
        b=hgsP2r53+QQxOU9YktEqo/4xOi5y/0BzpgE8MFEoCQ+XjnaJZhBfgm9xZgs91+GdI0
         Nxy/qoKFxpks4WKq995rx6NFSZq8JhwV1kbZd7y8T5YQgKoDhCkGHFwUBDdxUSoCxyhJ
         HO0Yah8aoQGL/NCWQCgkE+aLP1PmQqTqc2myxTFLbOkzwQ1dQScZu+7l/CgUd7oSdQOH
         LPVqwy+dQ3K/PjIGuIsBp2kwet0iL9Wm4I02B1M6+/ckb4nXAj8t1G/s7InLavH0uV4y
         klz+mkiMlH611rZTvdbsgqrOtJgvB4vravasYd7vOcqqpp1O8JxWzFZmAKdJD7PCLgBH
         xtuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=SMhnz8nmfeCa3vbVXb+2Iln/tpnO8JT5gUr+zaobt+Q=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=gKGbB8PzIeznolt5vchC9o3fucOu5I3XpegtDqEYHhT/wTwAeETyj2w4CIXQzC8EPN
         /5QFbOKF9zrsw6sGZx9Jn0njOPD1/WMZD3JQNyhTdBhLYZa47b8s39I7T3uesmd8Qy7C
         AdHQrNeNqzMzcZD7KgvV2L+vhuOcX+qQEvdt3CVTcOxl+78V+R7N3MuFd8eJvgnBpzf4
         DjIp+NwABL7Uj4oVobswIc32h3g3eUiYM/HWb2QJ+15IgA9NEgJLibtVMbXO7Tn9h5el
         sLM5w7PZ6twhWYpP42eMUxe0cAqbkerxMhf1MJqh1L27NKKU6p6lv8cUE86uGL/5JFjY
         08iw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792432212; x=1793037012; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=SMhnz8nmfeCa3vbVXb+2Iln/tpnO8JT5gUr+zaobt+Q=;
        b=QDrr5W3ElAYTGPdxmNlSO/ppv+jWwbSKAM49TznhHbqYpxu/d1QPHxiPuNeK4RkSSE
         yW35xYy6BKv5myNVFED4QjVQDV/9xcQ/cBXq1vCbFfhZPWjfk63Y3CR8IXE48v7dMjcr
         d6ReX9bRB19rjnVkv6XnvZ0VbAowAPUw6gOvjiiN3M22wiRk6LRwED8MnHfSIQD7rdMR
         3NyE5wsL6hsLE+CERBf/rUK2NDkGhD2x1QLAPnAgvgR4OPG+efADu4st1DWUVBT8APC3
         BNFiMAmn+PbdpciB84OE12VKupSo6i7StpW5ek5RSU0ZVQncWTqoJJaZRs2jw3kox7D9
         Vn/Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792432212; x=1793037012;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=SMhnz8nmfeCa3vbVXb+2Iln/tpnO8JT5gUr+zaobt+Q=;
        b=V4e2wpek4/9vYHasn4kqsCphWdDVYKJuWV34ba6oUeJc18ufjT9V1DVlbc1VCFFXQ0
         0ATyWwGavG2v2ENsLYuC1e2xpUz3pn6uV6hNSC3WZXQeNVfjb0KOrqDSWqORGk07eHc/
         gZPdhXnY8AZlcd1AskN7EQ6Lwjl8DVNWrs0Q2fpOyauL0C4sfh+cQjsSHx1UayzYmvmd
         lQcQ7wj047J5Aa99DjLLQkNIQNBIiMZix+eMpdQBzvU80KlQLcngm3ifEhp2KEx6ltpb
         +V7K/ZAD+hUG0oXjIFDdRrUlcBE3NDKSQwkQxtP9tt+Gnab1dIsl4JqJXDZ6CWqILvhY
         zeDQ==
X-Gm-Message-State: AFq9FYJ9p5f+d9TeE3GtHtNXRW9vV0EiY/lTgJSyj6RMPB1CkSyk7RS7
	OabXs9v5466IwRYd8Xx+irdoV/RiJxSdopOY5D2yY+XebmEyxsDiMAXY4p9Qo98FCHlHv2gQLLR
	lbTZpTEmLbY+TAygzdtfXgzipCZl47ocyxV2Wyuo/jw==
X-Gm-Gg: AYBFou0ea76CHRwT4MwG1Yf2bhq97R57rbjwVAM9zA2WI5WysgN2cw1/hddmOZrnWkf
	RovFvfnzWdzsvSFbzDXHMDa7/1kBV0XcMgPC4FkG562HXSQ5M6NR3qngpFBAllsxjgCzE2V0IRa
	x9ckLAEc8D+xA+2Okew4Sv9WAhb9as98u/dyCwk4QwL0IETi7D9CejWEB+IEs5agSh7lFj6GUjH
	57kdJkvjBypTOH41o7bMfJBz9WmyPTFvqP065P5fvFN+nEBdA7j2kPQrWA+DG7poh4/mU9i37xW
	PZ9Kxb1ofTsIeJoMyWncRytrjKxr45IvkVphXbxHPSAuxM+DC0J75KRe9lTpEhoraMBgZm564VM
	Ad4Ou+HaSEvj9/YnmLsT8924=
X-Received: by 2002:a05:6830:4421:b0:81b:9724:8724 with SMTP id
 46e09a7af769-844fe783338mr7812929a34.11.1792432211829; Mon, 19 Oct 2026
 10:50:11 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261019101117.54038-1-thnkslprpt@gmail.com> <20261019140519.GJ989762@ZenIV>
In-Reply-To: <20261019140519.GJ989762@ZenIV>
From: Avi Weiss <thnkslprpt@gmail.com>
Date: Mon, 19 Oct 2026 20:50:00 +0300
X-Gm-Features: AclHuK_94hVBSk9s5VslYdMxIjiFzqln8jlpNyVSWL-jzBirNVTnCTO9ahg02dE
Message-ID: <CAKOB7-aN6WBWYw+CTpCm9UfxS9Uv9Pbbyz9frdzhWyiqawwxJQ@mail.gmail.com>
Subject: Re: [PATCH] sunrpc: instantiate rpc_pipefs dentry before publishing it
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

I was thinking of, for example, an existing NFSv4 client when
rpc_pipefs is mounted later. The mount creates the dentry for
it's idmap pipe, while an owner/group lookup could queue a
legacy idmap upcall on the same pipe.

The upcall doesn't take pipefs_sb_lock, and rpc_queue_upcall()
uses d_inode() once pipe->dentry is non-NULL, even with no readers.
That seems like it could leave a window before d_make_persistent()
completes.

I think there are other ways possible as well.


On Mon, 19 Oct 2026 at 17:05, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> On Mon, Oct 19, 2026 at 01:11:17PM +0300, Avi Weiss wrote:
> > rpc_mkpipe_dentry() publishes pipe->dentry before
> > d_make_persistent() attaches its inode. A concurrent
> > rpc_queue_upcall() or rpc_timeout_upcall_queue() can
> > conceivably dereference the dentry while d_inode() is NULL.
>
> Details, please...  I have no objections against the reordering
> per se, but I would like to understand the scenario leading to
> such a concurrent call.
