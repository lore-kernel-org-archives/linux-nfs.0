Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 476DB413230
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 07:27:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789630034; cv=none; b=YoZ/gP2Tfm3xVGc2vG2o8PxkpEkbZE8siTLjq9nDmQTPik5NB3d71p0PuJTOz1dsrOSCYUAOdf6QAQ4x9OrX15XyB78bKiQ612jBQ5mnVlsbntP6d6a3a7MUCkTU39ccnt9OUBbhGnmmBXfYm2DW/cn0XRdwiK3drC4IKw8O18s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789630034; c=relaxed/simple;
	bh=hj1QYCB97vF33s4Pv0QkgwUhbdfUb+MhizH/QIM+oiM=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=nJb46IIBDB4f6WjkiwkzYPlpuIxYMzpi3OTMuIGiODgkzN3xAqXKtajqSoVqPF96di6AtxYNIiSFbn3ds6IoabUJqf0rFN8ozg+f+3xWFCSO9TAwSWI3v2jzzqIij9FAhW0H8NdG7uyPd0XwWu31veyDV+iiJW/i8UGcJQ/+XRM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=YLtJUii7; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=Ch+fbWEs; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="YLtJUii7";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="Ch+fbWEs"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789630031;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=c6SsdRzT/Bqt4wkU0T0q+RFo7GRVacgmeME637yMjU8=;
	b=YLtJUii74hVHfhmJOluoDer67yv9m2BHLFXxhmFqrKeqbvEHx8so3Fz1bKMP6HY4b48Uln
	TtJcdn9fTLOHZ0fxfS2efRL2pSd+i9Dx/st2GbC8JvBF8v/pAOKlP82u4r2lYjH/ZQsLtS
	hRZWHamUUUY6BUdGIFV8uQwfUJBoBp8=
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com
 [209.85.215.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-650-ataGIqtRMoy-xluDcb7s-g-1; Thu, 17 Sep 2026 03:27:10 -0400
X-MC-Unique: ataGIqtRMoy-xluDcb7s-g-1
X-Mimecast-MFC-AGG-ID: ataGIqtRMoy-xluDcb7s-g_1789630029
Received: by mail-pg1-f197.google.com with SMTP id 41be03b00d2f7-cc1cdfb337eso816338a12.0
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 00:27:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789630029; x=1790234829; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=c6SsdRzT/Bqt4wkU0T0q+RFo7GRVacgmeME637yMjU8=;
        b=Ch+fbWEsZLJCA4PmrCjyUQmU0DZLrq7hw8e+bojqDM6/bQvGPsA7gvjqz//S35QFpW
         IqkjON4GXV9YUzyHPZOaqduLUqCvaphUcCTwSppFeLza8unovJIRi/pQ/5w6IDXY45DD
         sCK2jt37cbau2HhRCLHR2hCGOmR2kVl44rMX5WroJWC0QEmGihtmM6tFLZ7AnPjtzLqM
         Wesh+zjflW+iLkNPyps2DPKPgIeeooQ7Ynw25hRCu/2WZani8t0TTT308YZrN6mCNCst
         4fFZyvp7jHGBGjUGTExD4+VwSi6fQ2qdtoMpvLuB2Lsg8k4COOZ18ln8ribOysD09nt1
         liMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789630029; x=1790234829;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=c6SsdRzT/Bqt4wkU0T0q+RFo7GRVacgmeME637yMjU8=;
        b=U3NbBTZwp4rpk3nRE5vKczeysTEexkbI0Ghi2ILvEkkBzY1T7i+Dyty31TTNZWOsJH
         cFSJzbrAk5vc9D1eIqnhONM3zAIVG+QN5CKHZoYVGTHw3HUM749pnJcBvk06mmW/x9sG
         SlMIYtEASByetMrx0H7m0sig+KeaLnVYWhVWZSl47+wS4qhzBULBs8epF+E2ALexIRAq
         txpWGoMOy3GIm2Agz1tkRez42J9z3hQ+nMBmfMRfPfgBDRsVjpTw20Xrnqkw9iZmeF0S
         hAHSZC+2nypWBKFiGO4kwN8tJHhZ6JPyPL6kR3tc1ltygBQjATHEYAdsRJMnzQIbLbnD
         VwuQ==
X-Forwarded-Encrypted: i=1; AKwUvBx2U4BlBQ2VDY21iKMJbHUjLAogohG/RZGQiJeJg432+HiHSAw+YnBqF59CHeFrXDNF7iogxrQu91U=@vger.kernel.org
X-Gm-Message-State: AFuF++mhh5gD1ARUfouMRv6aU6hbJhXngYz/m0GFWqLoWZ4TUvEF1gBq
	LDAm51AjZrGRyfrD3hyt7G+oxZlQNjx2Ghhwv/zu4pIbLx/V5VMiFN2AlAfLEJD4+98Y4tnS0mL
	ze9iP2pUR90q0+9sQKiFg6MrgrrtwClQShfaGThP8PToUX15+QWPZlrk0N76dMiiG3865OA==
X-Gm-Gg: AYBFou1WZVnHDd48WdynGJuccg/TdIC5quMwUV8YkGlG8xrqBJ1+D3F/pOrgUuh8gMe
	0RaDeMqqKGFH7KDgX4aQIGx2+P/Ys39LrvdK+0Uu067477Ey2zXPPY7Ip2ONzdpMNK2atKzbeOY
	qZzK5rWhOe76UYPGAxCUV+FEeQcaDzQ8TjWVz58yClInl0+DC5Hljb5YIEXO3bX/ixNt60BYvbu
	xxA3G0Sy5TNmsdDugrVA1qa98/a570Q386E4ZD85KUbgr8lIM/Rr313C5pzDVXizl467ccPARcc
	rzrsIcfgUXvJaK1f8MeSZiABEZn+WB49+Y3oac6XFfwviKiM+/ZGjpZyhCCNgdNawgphDyv+
X-Received: by 2002:a05:6a21:7107:b0:3d3:adad:f177 with SMTP id adf61e73a8af0-3dd5f7a8a9fmr14968825637.25.1789630028843;
        Thu, 17 Sep 2026 00:27:08 -0700 (PDT)
X-Received: by 2002:a05:620a:2702:b0:936:b923:4832 with SMTP id af79cd13be357-93bb789c296mr1011364185a.28.1789629700152;
        Thu, 17 Sep 2026 00:21:40 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.241.2])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-912428ac1ebsm26198906d6.18.2026.09.17.00.21.39
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 17 Sep 2026 00:21:39 -0700 (PDT)
Message-ID: <91d4a527-3eaf-4f19-85ae-da2c4ae5e44c@redhat.com>
Date: Thu, 17 Sep 2026 03:21:38 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH nfs-utils v3 00/11] mountd: bugfixes for up/downcall
 interfaces
To: Jeff Layton <jlayton@kernel.org>, =?UTF-8?Q?Mantas_Mikul=C4=97nas?=
 <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org
References: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/14/26 9:14 AM, Jeff Layton wrote:
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
Committed... (tag: nfs-utils-2-9-3-rc6)

steved

