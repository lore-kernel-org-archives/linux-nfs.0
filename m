Received: from mail-ot1-f49.google.com (mail-ot1-f49.google.com [209.85.210.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F16C3921FA
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 17:49:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790963368; cv=none; b=ors4PrtW64UJkrnNVd0txJISL7W63hyMyD0vymC9Ci7w7S8Y/7p1p59U7woy6wn6JgtgRhraadewTiCemNnlUkh9TgeYqMkg4NOuaMH9LtnMTzwt63t3SdpogU3pRkri0wCr5Rbuwelmra9o3yfuCms2TeGrsx6Xq89t3eTLQk0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790963368; c=relaxed/simple;
	bh=Clis9O3DzAIiuKdpFo10LD5YqX/iLjwQ0uEVt9WfQlU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=YYgOmI7pegoF7VAkwGr9RkgNZKwRXsaFTyirsJNuElvUjybZ7B9kQt2FkGtzzN/uX4+BObU2kD2P6BttgSNuYO42+9y+gQw/M+MzykXr1c966xecde3SqhxZt8neFWkJkoxxGo0oDY1S2uDKo2mmYGHjShTl2YjN6eeuN90Cw2M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=VNoMHgdT; arc=none smtp.client-ip=209.85.210.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="VNoMHgdT"
Received: by mail-ot1-f49.google.com with SMTP id 46e09a7af769-80587a80992so50268a34.0
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2026 10:49:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790963356; x=1791568156; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=88+fokyMsVb6J9AupI+rWvpXW46LjpXcwTir5FPJCNw=;
        b=VNoMHgdTskeMHRJi2gX4/hFFcmpuCbJe4IEuAYRyuj0CApJk++2U3QplNUi8V2E632
         LJCBBv5Kh0feH/KGI6BRcWQ3CNifZJHAus38Ok4Lf2OQbrITjWd5szUaVPNrVsDxsLrZ
         zMeBwSV6lcBAEJG8lV1cW02cUNYx63zxUawbPdTwBjsmeLt1r16U4W7I3GUpuPdtvc2Z
         jg3jMye27hxCXr4dzkhrCOP5l9TwTNeuYg4jeLXjknmA2zyD85WPcJGVuP5egCsyVVo8
         Xgtc/ZwdtnV8cVRx8EBUnhWe2bQwg7qQQ2f5cxXbNBDRUiKyEV7oF/BMckl29NFX7jUn
         VXcA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790963356; x=1791568156;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=88+fokyMsVb6J9AupI+rWvpXW46LjpXcwTir5FPJCNw=;
        b=Ox2NEIWkGuzcINpwnKE5f31iylXMrGE2TAZN+yqmD8vyWL+ixzsZz/lYd7uWfDvNrS
         zEojyambVTlhESfsfv7eU1sr1dVxQAJAEhI3DxQGEAbLv7p59MBviL1x25g9NVWCM/eT
         zUdpK3+unKtq07VjQc5Mm32Kh86ygeuNk7GnRsHgCZ7nanjZdFmUygIDzbqEJhEZcnau
         idy6ZMY/YIyFBDBpn+o+g3M07+y7/wJ9dpo1y9ArhMpe3u/giT19dmNkBGVz+Gu8OrlT
         yX1sZ5CjB+o0BqoHEZmvtEvkRea0UbFxCQU+cDuXupiYoZ6eh96eZbkWTtcbgskJE2OJ
         9FEA==
X-Forwarded-Encrypted: i=1; AKwUvBxggOnuOXbit4G82OVHbPrzi82LcchUpIyMVqkkLvKQzkVHOmo5ah7dtGdSkfraG3MG5j4FsiN7FFQ=@vger.kernel.org
X-Gm-Message-State: AFuF++nhb++dpL4maSAWLUa+ftMknpqWX4qGoeDhX/HcCBAYspBPmAyv
	gHsDWygMmyB3jTwsqpWrCR+BphXnM8hLZlL50ilFal5vGUW2Y/SrX2kyciJlkn98nd8=
X-Gm-Gg: AYBFou3ak3NTeSaG0XbRhRrrdRqWQV8NrijkZEEZYrlJx5m6BJ8FN1aWx5TIPxJ0gQj
	NugHDiSOzFfOewayGCrfCD9828ofue+r1ST8fdKfVyyb8nduVl2PthZTKRFmHvbuJI7VnHsgAau
	rC2cnKifHqnzREHHidttttYPjL+2cw9d9e2MqpCWfF7gccT+DfmsMlEdVQjjgzHFl2xKg/FXdIv
	GXie5ODQLdynxyFml7jMrxC9q/cRvxFFPvvZPo9nd2aEolFu/OTSutAbM7hLRfi8yd0An7nOPVU
	dpljtFMlsyTnzTzsTGtns8hZtXmm1FREBePT63o0v7mtUel7xYqLT94MAFGUEtNz2XZLXur1bhv
	8yWS0azbq8Zx6niNEXRs+zSZODjRsMVmADKvnL5kNoVBlLfuiv3V2ctZ5G7+yrg4ea/1QQi5v0s
	1L28tE72gL3ts4k1iO+8IoaextU+okHiKldDM+sfNG+Mf6bjxL2LmskX4QyExDlO2RKSYLUTODJ
	ofaYXzXl83Q/6uu/A==
X-Received: by 2002:a05:6830:2111:b0:806:d79a:c932 with SMTP id 46e09a7af769-823fd5fa770mr113543a34.20.1790963355628;
        Fri, 02 Oct 2026 10:49:15 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8227a373c85sm3543445a34.20.2026.10.02.10.49.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 02 Oct 2026 10:49:15 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: make the nlm_file reference count atomic
Date: Fri, 02 Oct 2026 13:49:13 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <45544DB1-FB60-430B-BE44-73ECBED11752@hammerspace.com>
In-Reply-To: <509cfcc3-c413-403e-a4b4-59ad8ddbd774@app.fastmail.com>
References: <6469ea852a2ad9d650a0bcdc8e2609bbaaec9f98.1790948497.git.bcodding@hammerspace.com>
 <509cfcc3-c413-403e-a4b4-59ad8ddbd774@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 2 Oct 2026, at 13:23, Chuck Lever wrote:

> On Fri, Oct 2, 2026, at 7:16 AM, Benjamin Coddington wrote:
>> nlmsvc_create_block() takes its reference on the nlm_file with
>> file->f_count++ while holding only that file's f_mutex.  Every other
>> update of f_count is made under nlm_file_mutex, and can come from
>> another task: nlm_traverse_files() pins each file it visits and runs
>> from lockd_down() in any network namespace and from nfsd's unlock_ip a=
nd
>> unlock_filesystem, and nlm_release_file() runs from the release of a
>> GRANTED callback.  An update can be lost, and the count then reaches
>> zero while a reference is still held:
>>
>>   BUG: KASAN: slab-use-after-free in nlm_release_file+0x504/0x7e8 [loc=
kd]
>>   Read of size 4 at addr ffff0000a738f6c4 by task lockd/11494
>>
>>   Call trace:
>>    nlm_release_file+0x504/0x7e8 [lockd]
>>    nlm4svc_do_lock+0x2bc/0x468 [lockd]
>>    nlm4svc_proc_lock+0x1c/0x30 [lockd]
>>    nlmsvc_dispatch+0xa8/0x200 [lockd]
>>    svc_process_common+0xb08/0x1b80 [sunrpc]
>>    svc_process+0x424/0xb70 [sunrpc]
>>    svc_recv+0x1680/0x2408 [sunrpc]
>>    lockd+0x148/0x288 [lockd]
>>
>>   Allocated by task 10651:
>>    nlm_lookup_file+0x2a4/0x5c0 [lockd]
>>    nlm4svc_lookup_file.constprop.0+0x4dc/0x848 [lockd]
>>    nlm4svc_do_lock+0x284/0x468 [lockd]
>>    nlm4svc_proc_lock+0x1c/0x30 [lockd]
>>
>>   Freed by task 11494:
>>    nlm_release_file+0x46c/0x7e8 [lockd]
>>    nlmsvc_free_block+0x1a4/0x298 [lockd]
>>    nlmsvc_lock+0x2cc/0x1a80 [lockd]
>>    nlm4svc_do_lock+0x324/0x468 [lockd]
>>    nlm4svc_proc_lock+0x1c/0x30 [lockd]
>>
>> That is v7.2 with commit 526c49cff3f7 ("lockd: pin next file across
>> nlm_inspect_file lock-drop") applied, with NLM lock and unlock traffic=

>> in one network namespace while a second namespace mounts and unmounts
>> NFSv3, which shuts lockd down in that namespace each time.
>>
>> Make f_count an atomic_t.  Files are still only freed under
>> nlm_file_mutex, and nlmsvc_create_block() increments a count that its
>> caller already holds.  It is an atomic_t rather than a refcount_t
>> because the count rests at zero while only locks hold the file in the
>> table.
>>
>> Fixes: d9f6eb75d490 ("lockd: blocks should hold a reference to the
>> nlm_file")
>> Cc: <stable@vger.kernel.org> # 526c49cff3f7: lockd: pin next file acro=
ss nlm_inspect_file lock-drop
>> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
>
> checkpatch reports:
>
> WARNING: From:/Signed-off-by: email address mismatch: 'From: Benjamin C=
oddington <ben.coddington@hammerspace.com>' !=3D 'Signed-off-by: Benjamin=
 Coddington <bcodding@hammerspace.com>'

Checkpatch levels up, and my mail gateway rewrites my from address.  I'll=
 fix up my mess over here and send a v2.

Ben
