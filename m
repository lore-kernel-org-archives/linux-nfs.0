Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81B3052F282
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 21:43:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790804634; cv=none; b=F6OiOc1yESLmrs0uHdKADh6ofFwlYOVZOtECXBUWkzviIyi9/WeHdeTBfMbMBe3fFI3W/qae+AH3LKRdXaTvamNrwKOmzEPV14sgiN++D2JwMZOc6PBjgZlnIHa/167voa0QHyg+Cg1LhxrFuhakk/qvqNyeICB9Er8mKaDQwfI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790804634; c=relaxed/simple;
	bh=6yCeTiJvm3FRFm4u9anahsTQh03Sw92k4imBxFN0vSQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=gUjSOtl5lVRWiyI8STCj/HXs9yPeUMYH95iruiNa4mx79tiFFHTEDGMJELEWDFazwV8KncCd3wVXWlzX+g+thfcFywIJR8V4m66EHSJH/uF+gpCCWRxMiReLzSukPUexw1BqsrPRpeLNqrEOpjozPTciVG+vLURMcUCJj805hII=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IZGDH16q; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IZGDH16q"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CFEF91F000FF;
	Wed, 30 Sep 2026 21:43:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790804633;
	bh=ytwQT19qVl46mNpNSJGZq72qEGRQjaSaMFQSZiQwWnU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=IZGDH16qmVlQHBvwteo0XFGLFId512IIPwgCjLbaH58TmZABkvlBeO4XfBCgiW2Bb
	 gWPj/KVE3ci0WCqElJt5PieNgYBRXscfAosx86yBUy8r6IAkYYoFMrin8MPEHe/XIj
	 YkON6HY/0Rxy2c0H8RlaYhDwr/LuKCO7/HtoRzEaGVFK1yOV4JM+N7sMyXTncVuMii
	 RmLCOA5PPH21IRl9xcX4BqdzVne/WcrCSd2rZzqPXjuONjOEFBHffvG7tFnYRgjfiq
	 a7ci6dNogVLxY/ZzRwWuOwMpEnHZLG75Ie8sVXMYoD1wkVZ6g0jd7KHQuL5pKnHrro
	 +nPlvNw6cJAZA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id D0C8EF40066;
	Wed, 30 Sep 2026 17:43:51 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 30 Sep 2026 17:43:51 -0400
X-ME-Sender: <xms:l4K9asBtoEFnKU2DxYe833DF5pUYZERhmzTyiGm4Bbu9LbsAgn1_zg>
    <xme:l4K9apUOeJwZ_oyJO6V81FIrorUP19WLJnqPAxY-DeMXK2l_LHwCoa7pfhu8KmfEf
    ozg_ayr1EELLv4fwln1iekhI-AbIow83ZtuAGM_I3ORz8U2H_6YOnBqnw>
X-ME-Proxy-Cause: dmFkZTFzkily9ToWPe0DNVyM4v6ng/yjSg3UEMUv76hxOOK+Az1m3Jx/HTGZfwUEp/9+Z1
    rx/YH/iGNPegcQGbpU2DQ1xYBVDsLYB7+aratMCZ2lNHCJkgy8Z7pvnvr65/LLpLlaeK0E
    C38WeCEyUibUo6/c5L/Icm4hEM7mbQeSX/C3J3CHdFt/SjLkl+Af/CViA9Sdj/Q+cSYdXm
    GC6zgLMoHghdpEj9u2yjy4+9pJ3RfiAOEgOpMqgbDAOHsHRk1NYDxsUgU0Ou+8BZnREEjB
    070fj9nq64xG2/zCgyzfZczpxch5UIDkkg+91vXknslwIi6v9lOXSMdUa9H594WIMwqzlO
    qNykUhyaRaV14lZYzl00tWm2hIbIbobT6tI4RWQv2Dh/+Mg2Cf2zZsx6rwr7K5+21K42lK
    bVOH/7cIpjxTyDFyjQrEUoH4pNvgg0wE0Qf52pD6eIHWWgA3dU+3MqBu2KXzITppXFz2gU
    9tG7e6vR9z/G7vykhjIzqwaYmAcT0lNUbDzRU61kMB3J3Z/ZNXydb3YTi+1u1zOe0rWW5h
    gFKC6ve7+6+Q1+kyP9vOyarI96AY0axXpLBPmXFJROpPYPz9Vh0ka3+VZQVLR2tF+nywbw
    kk8n+Yqai+cb1BQDKwyQdoa0rltdOyCl9lznKwbqDbYjvQoDklDP8Ihf3OYQ
X-ME-Proxy: <xmx:l4K9ahfdhtPMKGqe-4XPcslkH5bVlpaKFCva5dBuRKrUf7JN7bPQ0Q>
    <xmx:l4K9am9QDeepzsL1AnhytKLvPE-vC61I-FS5XC1YkxULq9rRg1Xcog>
    <xmx:l4K9atl0pClBCBiEUbEETq883A0zOeESJ9YTFnCJh-OeaYhfkvNehA>
    <xmx:l4K9ao83nmwP-jazr1Y84ucWpz4EuG6cxd66ylhFk7fCPvxjE3ZQyQ>
    <xmx:l4K9arkr7wxwlCStLrF7uaJ3BhklXYdL6zTx9X3uYYWH-iesmrjOmdjd>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B26F6780070; Wed, 30 Sep 2026 17:43:51 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AKn1pY3y9srV
Date: Wed, 30 Sep 2026 14:43:31 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <0ee41b38-3f36-4750-ad60-1a59646bb970@slotpi15m67>
In-Reply-To: <20260929231329.22018-2-snitzer@kernel.org>
References: <20260929231329.22018-1-snitzer@kernel.org>
 <20260929231329.22018-2-snitzer@kernel.org>
Subject: Re: [PATCH v2 1/9] NFSD: mark the direct middle of a split WRITE
 IOCB_DONTCACHE as well
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Since this one carries a Fixes: tag, the stable folks will pick it
into 7.2.y by itself. The rest of the series won't follow it there.

> diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
> index 0fd6e82478fe..dc50c930f976 100644
> --- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
> +++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
> @@ -130,6 +130,16 @@ Misaligned WRITE:
>      segments because using normal buffered IO offers significant RMW
>      performance benefit when handling streaming misaligned WRITEs.
>
> +    The O_DIRECT middle segment also carries the DONTCACHE flag. It has

In a stable tree this paragraph will sit directly below the existing
"DONTCACHE buffered IO is _not_ used for the misaligned segments"
sentence, which the "also" contradicts. Patch 2/9 removes that
sentence, but 2/9 is not a fix and won't be backported.

Let's replace that sentence itself, so the document reads consistently
in the LTS kernels that carry only this patch.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
