Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19D2B4AFE19;
	Thu,  3 Sep 2026 13:41:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788442930; cv=none; b=B9ZoQxk4gzOOpimfBm4IDtuYs/zBz/wsbHZNrPlDPcFh1DivD0hD6bk2G9Cn6Wht013CTr+jE/QID+/yos9FVYhT3t67aExQONA6I6dlmhXIV2YGlYHLsXmbuitWg5DZ6dyi4UyRS6Gv7EIBJoTscFXJUgrIywa22Mph2r4/ZGg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788442930; c=relaxed/simple;
	bh=wfAQ8E+IKgFGyC/cVeyKjEYkid2jrjWD9NP/PX8wz64=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=C5fClXkPAnW5k0QVlONtigDV2ReyZg5OVT3k9FoB5z6D1Z6tDaLp7lHlVbiug7SnUaepM5VinlS41n1j4Q5dcjpGRsMm/ywUq1xER2ufjE0KfyfDZnKSIUPnFeLFvP/MN1PBQLqauyjqbEVKWNIfjoltgNMn2zw1lQtIfbux4KI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nbFrnCNk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nbFrnCNk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 888771F00ADE;
	Thu,  3 Sep 2026 13:41:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788442915;
	bh=geF6WALf7xC0WTU/xL5vCeQU4cild6GxbwLKnsro0qo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=nbFrnCNkHw6aY19TTU8t06idTyAJp8sjQpIrjIrXOWFAcIO4Tq4ldv3IicKOXRhba
	 F7V7dxBc3sSWT5zLD9xro5zmSAX8+LQueiFqXhmspQhXEr3hKfHADMccZCgQTjeXAM
	 WcT72Nvx6IdLJQwdGaEO8aJlk52D4uJCWbSpTm4epxuyvUPajRF9ja1QFgBKcuICqF
	 K6JykQjftr8dnRjs80nWbSs3Lbceae3vOHkQWVCtw6D+L1k1/l98/9ajv3be+p1Rpx
	 mugcZ3xa7QDWt9qmUJegZ3DqwClW5IJavoVR2kDXfqrnerouANIONd/dHXIXeVl0OX
	 TY5OTl8iwcjLg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id ACF33F40066;
	Thu,  3 Sep 2026 09:41:54 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 03 Sep 2026 09:41:54 -0400
X-ME-Sender: <xms:InmZao6W0C7NzE7ywIrM2UqwEQvFCEGuwSk_dqXIRweaqLVm6-pMrg>
    <xme:InmZakuCiiAEniZh7XvYbZtTCIjIqMPprG6uHnD57c5zlkFmuOW_q6ZWrHyW3U4E8
    0-2UoOwb9GlXh6UWjTNN52JlStnjt3BxotkXepFas9SphDw4bV7Ks4c>
X-ME-Proxy-Cause: dmFkZTE53fCEih77ubYil0PnVXNTDMewFXnj9ZnynhIhwXaO4LHUiH1n+lNk2du0CVeHat
    JBFQODxa9bJKXoUunpv7uBPFH3jz/DtaGCyq3+b68m9mym93HV9yE03SZvmXgY/VDmq9wN
    6CjH48hmGKAN4yNjv5bdbSCipfwxvwqrhM1W+2t9VwK3JBw448tGmc/S7QyuMUWfY7z+oj
    6KMJ2nvLYaQxzSQ+AXe1E/qtfYZK4nRxILKZuBt2+b+wYylDFtVqQoplWfJTfasR2eNPQL
    AuWq8IJtSiN1OhGmr+s+X+WR0XcZTFujz9pppinHDJbyQrqZ8MIhkc5RWphgSFaxFZeYmH
    yS6DQ20yXq4ltZl2zeLn1wynUHhV9ph+9gmSyfCW9R/Tt0Qxp1fK6KMzObUODm7CYCbAYy
    HoA3Tnpre3GB3rutQ2RcMHGD8uUO1FqbdZwo/6ETDTLcXheADxTxbqy0u3KEFIVhTf6L/n
    8M+q4FYM01bon/IbOoWnyBcj7IiovIFVOQj/M3g7Ph//o/No+GF5q0tdDBft1+r8Qa/mJo
    rqqvFRq6XTANIcVy6doF9MFfEPLO0O/oDeIJtYfNpqfVEDlHA3Ugg9r7918u6jMpfZJNz6
    tkY3uEHMStfAdTzrrRqFVtaQs43PoaJhD874KmQ/DwTePHy+7G7uA+ki3TVA
X-ME-Proxy: <xmx:InmZal48htpUTb0SxjvL95nxnIfCL3pGx0whPlNj1RYcU_yBwquuFg>
    <xmx:InmZat1GPF9vTEYq_in3ZJH3duYtbSR_OHbzqzHlPizj_OaLz9WzEw>
    <xmx:InmZarcwGbzO_OnVTg1gK4IyK-alaLVdlE0_htiMaQGqDookeYTWEQ>
    <xmx:InmZajcsAFK3I3fNnCBKZNY508qYVfBy71jgZxF4oHCgpwGKxqwxDw>
    <xmx:InmZamwZxHFotsmF3MdKZkTfquOt-plPXbtHT9bF8EktbFKS-wAFtnNj>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 908DF7811F0; Thu,  3 Sep 2026 09:41:54 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AD3fe1Cggn43
Date: Thu, 03 Sep 2026 09:41:38 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Tejun Heo" <tj@kernel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Lai Jiangshan" <jiangshanlai@gmail.com>,
 linux-nfs@vger.kernel.org, "open list" <linux-kernel@vger.kernel.org>
Message-Id: <d9bde347-6ca2-48e7-b0d2-768bfb7c653a@app.fastmail.com>
In-Reply-To: <aph6yYag8LeZxmyn@slm.duckdns.org>
References: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
 <20260902-performance-v2-5-b71c0c082f9d@kernel.org>
 <aph6yYag8LeZxmyn@slm.duckdns.org>
Subject: Re: [PATCH RFC v2 5/8] workqueue: add workqueue_set_affn_scope()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Sep 2, 2026, at 3:36 PM, Tejun Heo wrote:
> On Wed, Sep 02, 2026 at 03:28:50PM -0400, Chuck Lever wrote:
>> An unbound workqueue's affinity scope can be changed only through
>> sysfs. A module whose workqueue contends on the pool lock at the
>> default scope has no in-kernel way to select a finer one, because
>> alloc_workqueue_attrs() and apply_workqueue_attrs() are not
>> exported. Exporting them would also invite a caller to apply freshly
>
> BTW, please feel free to export them.
>
>> +int workqueue_set_affn_scope(struct workqueue_struct *wq,
>> +			     enum wq_affn_scope affn_scope)
>
> No need for the line break.
>
>> +{
>> +	struct workqueue_attrs *attrs;
>> +	int ret = -ENOMEM;
>> +
>> +	if ((unsigned int)affn_scope >= WQ_AFFN_NR_TYPES)
>> +		return -EINVAL;
>> +
>> +	mutex_lock(&wq_pool_mutex);
>> +	attrs = alloc_workqueue_attrs();
>
> Maybe alloc outside mutex and use alloc and mutex guards?
>
> Thanks.
>
> -- 
> tejun

All applied to v3 (still unposted). Sorry all this has taken so long.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
