Received: from mail-oo2-f34.google.com (mail-oo2-f34.google.com [74.125.231.162])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D043599A46
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 18:58:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.162
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788893896; cv=none; b=dR5VsRGbH82aMisiriV1Ceqy8ua+07eqe7sATE/vIz8o3d9+WaEXkbu3snPAet9luUhFCoGvC1CCkP0vxECJlrpoyxqxaObuofn+pQr3Jx0xz76VuEAYSBfdGhDhwp9d+Ec+wOsHj/jVuY/q6NxMOJRP5qSEOQR406N5hsDtDrY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788893896; c=relaxed/simple;
	bh=VQ+iQuQRBq7XYuhFR4aT8Tqm8yU/BLeiAcpSxN8RLXs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=iw31P2h/FgZj6FSJqZxk3JhhZlCg54wRCpTF9833GZwrXJbUeu9+jEZneXoDqqo+G3UYE7PVSK+zm/g48S8FOyWavj7qNHW6lb3jop/sPM6IiHigtiomNA4fVWeyECVMbCrhZ9KDg5aBmKfduwA1qWpohYi2H4MW2GHqFeK6z8c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=ig31ALge; arc=none smtp.client-ip=74.125.231.162
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ig31ALge"
Received: by mail-oo2-f34.google.com with SMTP id 46e09a7af769-80032c08611so231099a34.3
        for <linux-nfs@vger.kernel.org>; Tue, 08 Sep 2026 11:58:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788893892; x=1789498692; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=b0yd2Dc/7PsKv8sBzVQchdmBHQXLoVPsirwKQFVdqDs=;
        b=ig31ALgegXekuTzjIzhnyG/WNuO84uOVvK5vHKKRQAhUeCff1v4h8yKpVG07HEDTXQ
         cYZXVjr4EFgWqDuBveJORC2qpURd2f32JbimuyGgNU4rvqrvaYJ974vdEauGtbVsAryk
         Kqu4AfOuqaP3tUtQAS0J1ID7xPwuxMIJTe/upO4QRPFIM/a0HPfwxXjnPlStQdbbAcD1
         qYvYUqey7L0vWjpvtQqD3AyzgYE7RJz22UH6vmgl6YiKA3pbc76PDUxPUpJNeF3Q45wf
         6fA3S2C8IsBXJSZCKWf4k0404W9vy0YPJhVCOFB72gVWV1XFHQZ67S/Mt6yA+B3ER+hy
         9paA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788893892; x=1789498692;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=b0yd2Dc/7PsKv8sBzVQchdmBHQXLoVPsirwKQFVdqDs=;
        b=J/x3sNKIe6dAmHt1ujXZPvjTdOCBk+JsfHp3AU/+PMWlDhYSLgzVovonq5x3r6+9dE
         xOEJYc+qL9RSwrMv/7ukUYS8+dUqCYS+5SEOJx/ClqnzA+xDs7OwEvOvWCZKy+xtVwiB
         Ujfbs0JnSp2C+ODvdOkQPoN5EPBqvp9Lz/b2jek6/LnSOnfySD+a/xYgb8Y3Nu5ewTCP
         MEJ8AuZ2pMN2GJ7WYJRCODLBKOd2OgtnUCL/Q5qr/VlaIWw8DTSOjPH5g1jKAZgbpzzf
         xMfssCx+8gGi1fkf+wvwbjMiwAa+rfc618cF3x9AUnXOX8IIKrKps9hcN9i01xjqcFKF
         4sKQ==
X-Forwarded-Encrypted: i=1; AKwUvBznZJpX4w7XYXZT9t95aRqsOBLVKpL8qytZU5Gb1N2ia+wzMEJpcX2cKZFBdoAbbQxTDnwp6T0BUg8=@vger.kernel.org
X-Gm-Message-State: AFuF++muQ8UzzJG/t7R0+IOBXO2WBsFNlroNYVLRGdiM7ajzGbqFrMi3
	NnUxaPSISwf+RGSqllm+AhsCQkxEPCQ1Ldocx7Qz4dbc8RLTc8eDhB8et5Ov+DH1ark=
X-Gm-Gg: AYBFou2CCYgw+OcQ6wLJaovaqzyWABVDzXX+1orRjrtDTRAAcSU+dU21lMLeVN77Q8L
	EDpp2KCM0R67IJGIlmU1vtav+FsOFb9lx1gY6Gtllcgw7G2pW49+EiUABJE+GV2qd3JJEzyu15b
	IGWfK2zPuYUs/+u7y3MsdwhEexMkJrza+Q/0YbM6HEN+wNL4NKjCLxN8nrpwtqGhI0uI1tstIrM
	Vc9u39JEmzQKh/ljpPbrUsbib1vCnrsWv8/SwrHT/DvFU9h2Mf0KU1hAi5rJHdixzpOGWlZGWPw
	Dazg2n8dbVzsauO5D/ppXhvGBH0TP6ozw+XX7LkEekMxmGij8Az+XUu72SuoEIlG2Ck8UGGf9Ix
	Sf4Gl+poI+5IYQnwR3L8Ur/E7DVcfPiLpqiI+tX+Aa6kqv5PrcCmffw/kYHTJY7tzB/yyJTfPZ6
	EWulFSrG67id8+B4/d9NzQFtqTHEvCFzjv7brCmZ0/z5oyPLgeWU45yYYPYnaiJH9eLewOhDD22
	QZcWiaWs8HMZsd68gg=
X-Received: by 2002:a05:6830:67e5:b0:7f4:e350:b533 with SMTP id 46e09a7af769-800ef48b4dfmr2121694a34.4.1788893892308;
        Tue, 08 Sep 2026 11:58:12 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7fcc45d7852sm9515319a34.20.2026.09.08.11.58.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 08 Sep 2026 11:58:11 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Anna Schumaker <anna@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
 Jonathan Curley <jcurley@purestorage.com>, Mike Snitzer <snitzer@kernel.org>,
 Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH v2 1/6] NFSv4.1/pnfs: suspend pNFS on NFS4ERR_TOOSMALL
 from LAYOUTGET
Date: Tue, 08 Sep 2026 14:58:10 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <3AE72914-37A0-4ACC-AFAA-57BE5052F5BD@hammerspace.com>
In-Reply-To: <15ea408a-5e87-4a65-ac94-10e357683a8d@app.fastmail.com>
References: <cover.1788453839.git.bcodding@hammerspace.com>
 <a906e6ed5bd3fd560ace313a6b64491e1da835ab.1788453839.git.bcodding@hammerspace.com>
 <15ea408a-5e87-4a65-ac94-10e357683a8d@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 8 Sep 2026, at 13:35, Anna Schumaker wrote:

> Hi Ben,
>
> On Fri, Sep 4, 2026, at 8:56 AM, Benjamin Coddington wrote:
>> If the layout for the requested range is larger than the size the
>> client advertised in loga_maxcount, RFC 8881 Section 18.43.3 has the
>> metadata server return NFS4ERR_TOOSMALL.  The client caps
>> loga_maxcount at a single page, so a flexfiles server that stripes a
>> layout segment across several dozen data servers produces this error
>> today.
>>
>> The client has no handling for it: nfs4_stat_to_errno() maps the
>> error to -ETOOSMALL during decode, which nothing in the layoutget
>> path recognizes and nfs_error_is_fatal() does not consider fatal, so
>> pnfs_update_layout() clears the layout fail bit and returns no
>> segment.  The I/O falls back to the MDS, but because no fail bit was
>> set, every subsequent pageio attempt sends another LAYOUTGET that is
>> doomed to the same NFS4ERR_TOOSMALL.  Files whose layouts do not fit
>> the reply buffer never use pNFS and pay an extra round trip on every
>> pageio.
>>
>> Map -ETOOSMALL to -EMSGSIZE in the layoutget exception handler and
>> have pnfs_update_layout() treat it like NFS4ERR_LAYOUTUNAVAILABLE:
>> mark the layout mode as failed and fall back to I/O through the MDS.
>>
>> Fixes: d600ad1f2bdb ("NFS41: pop some layoutget errors to application")
>> Cc: stable@vger.kernel.org
>> Assisted-by: Claude:claude-opus-4-8
>> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
>> Reviewed-by: Jeff Layton <jlayton@kernel.org>
>> ---
>>  fs/nfs/nfs4proc.c | 8 ++++++++
>>  fs/nfs/pnfs.c     | 2 ++
>>  2 files changed, 10 insertions(+)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 04b1987115d5..e41c792a2725 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -9680,6 +9680,14 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
>>  	case -NFS4ERR_BADLAYOUT:
>>  		status = -EOVERFLOW;
>>  		goto out;
>> +	/*
>> +	 * NFS4ERR_TOOSMALL means the layout for the requested range
>> +	 * exceeds what the client advertised in loga_maxcount (see
>> +	 * RFC8881 section 18.43.3).

^^ gah - Jeff asked me to drop this comment and I forgot.  I agree its
better without the comment.

>> +	 */
>> +	case -ETOOSMALL:
>
> Should this be NFS4ERR_TOOSMALL instead of ETOOSMALL?

At this point, its already gone through nfs4_stat_to_errno():

{ NFS4ERR_TOOSMALL, -ETOOSMALL }

I definitely tested this case thoroughly..

.. but yeah - the mixed error types and the comment in there don't make it
clear.

Ben
