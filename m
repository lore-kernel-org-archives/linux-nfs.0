Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 494364756DF
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 13:29:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792157376; cv=none; b=ILBzcw38rLUQ/iNtPPUjG9Qt72JKG/cFI1z9rZxEwFtAXCi+0RlepKZ2ziXN1P6eSjDYwC6Z/nwPpK0m7gktYnZLoherBrpcxm6aCroQdh0/oeWNPA4l1IY/Fd06lviVFPT/Icw68nA23TJOHR6NWrxHfyqznvl+2++TkZS3lLI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792157376; c=relaxed/simple;
	bh=dGZYlTPTKGUdg2t85Of8XY7Gpw0oY7t+7tnGqzyH7vs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=h4fhZNYc+7copIaCxcTkz7kjl79pzr3jGPYVPnEuDFEzTOu3THiuQq5fP9+CulvB6yRGsv2akC2ceao76zXV+4Kw4QR4rhgK57moYmdctlNLjOxMm510p4J/+kJciS7Jhe4wHI0GmBnaR/s9wwZfuS8ZVDMDprf7bUPU4iBG9uc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=PrLxjYa+; arc=none smtp.client-ip=209.85.161.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="PrLxjYa+"
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-6fe4372c5f3so1515510eaf.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 06:29:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792157374; x=1792762174; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=yu52ozP/xwduV+gktiJFORSGH2ukly0hatSnmZTJEOc=;
        b=PrLxjYa+PLGYI4TT//1O8/2h0D7k+4aoOkJPoBUL6zBaguGQHXdOI4VeNE/svTFmhk
         FaEk8vg7b/22/725D91jTCenRuzQBf2QWYu+BKU70zb+pSA8u8T2NkJ526g+5QHOwP7k
         HNZ/A8hMIzbr77NxgwbxhOIRGZXlCIYyAI/RtX9INxHXka12spexMS6lfj9+8yom1Wk5
         Msj4GQEoM6JZkYkc3F7L0XQd4Kj7UdhUS9hvpLcn5y48m4z1yV1cMTCo9qSPJlfUyIzQ
         UQcYVand+1v103NOuMCf2t+smDjJR9dmx6v/CMo+9NUgiRgQiKUfEIKharTQZ9N2B0Iv
         BhKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792157374; x=1792762174;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=yu52ozP/xwduV+gktiJFORSGH2ukly0hatSnmZTJEOc=;
        b=N8/mP8KrFB99SqQbvKCuT/SU25UAUfUKWq+CnNUwYXxiObbBBMSsJJF4bXQuIMMu3D
         l4DhpssFa/iYhTuZRVgsNChFvj6OQtWIr6ZFOFs1pW7fE4QjjjedqHMWsDNScGr8aqjA
         +xrOcVSwmNGyWqQRVVv8QLeeJdVz0pRohDjIs00j6CebMZczlqGDorBos4Wu5fSHJXAL
         5v5rRgjXH/2Kf4/gZv2N9XAgS+GiD8l4XKvuTlc8kDsC25nmY4ZLsumjqQArWjJJWCX3
         zY8F9JNYk+kzUoDC2oIIAxDBnmgdSGZbjybFFznT7BIKAs6v6fJsa994tf6yOSXVdPTh
         YVxA==
X-Forwarded-Encrypted: i=1; AKwUvBwieYijxRMTpnbTRB7amkpludOxNJW8c3HkdLJnnXX1w4x2nPLqlDIMTFer3W+s5AhrDA/dE1lGgck=@vger.kernel.org
X-Gm-Message-State: AFq9FYIwjWyfRirPFrr85SLMM05S4yFDEXEysAOyFb3aq8XqZbl0KbA1
	BgSH+lgp0gJmb01/rEB1YPkerEkbxkCwqHriVO5r1ST9gIAl4otOet2/ubTOY3C8+vs=
X-Gm-Gg: AYBFou2/lZU3S9ht2TBk3XlcoEusMnzPZgnMmOp1oq4uXeS8e99jXfUy5334JJIsdBl
	h13gdXXJ4m8Wb8oCwSlsM3556JssTWj7fIpDdOaGzzD4pwkkxvxDvBVS1XqqlVwhIESn+Z+OIZU
	7FUXnoqApCbGSCtPTlMgu4UwppEt4hqrCtzc/FjWQRb+PKphH/ZboFqX0skCZFD7SaXO8z/6haW
	DdS6IhgkHEUzCtAdFr/UPi+yQmH/vMrZODJb02EBDJWK1pEEbrhtjLAnu1C5N3cVgI1O0mxsN+F
	80wwJgRAJrsZOJguvuwblW0sPARgRgl7h+ZlRvA1nPdqMIHNzVoYVMOhO0mFk8IMts4lW/kikh4
	Z7pAsRKhEmxsm/jSZATruiiA5ThSogvcDRUZFigqyMHZmAMpN40ky7nTv9Nthg04il4raocnd2h
	0yv2ilsGWefxmEAkhByMiDLHV6uvY1svXBRRuPSThhy5jRlbHrjV1bB8xTfAleiPKqU5emLU41+
	8bNABFI2R8lTdkafA==
X-Received: by 2002:a05:6820:82c:b0:6f6:d7e:9ed6 with SMTP id 006d021491bc7-6f60d7ea657mr12490162eaf.8.1792157373974;
        Fri, 16 Oct 2026 06:29:33 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-842a4a00f15sm1810129a34.8.2026.10.16.06.29.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 06:29:33 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 linux-nfs@vger.kernel.org, Daejun Park <daejun7.park@samsung.com>
Subject: Re: [PATCH 2/2] pnfs/blocklayout: report data lost to a failed
 LAYOUTCOMMIT
Date: Fri, 16 Oct 2026 09:29:31 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <DDDF3FA1-0C97-402A-9657-5D88D7096C12@hammerspace.com>
In-Reply-To: <20261016125620.GB5871@lst.de>
References: <cover.1792097970.git.bcodding@hammerspace.com>
 <735df39cfa1873f3ed5b20702fb7d7a79cf49fba.1792097970.git.bcodding@hammerspace.com>
 <20261016125620.GB5871@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 16 Oct 2026, at 8:56, Christoph Hellwig wrote:

> On Fri, Oct 16, 2026 at 07:36:39AM -0400, Benjamin Coddington wrote:
>> From: Benjamin Coddington <bcodding@hammerspace.com>
>>
>> Data written through a block or SCSI layout into PNFS_BLOCK_INVALID_DATA
>> extents stays unwritten on the server until a LAYOUTCOMMIT converts
>> those extents.  When the LAYOUTCOMMIT fails, ext_tree_mark_committed()
>> tags the extents written again so that a later LAYOUTCOMMIT can cover
>> them, and reports nothing.  nfs4_layoutcommit_done() also zeroes the
>> task status for NFS4ERR_BADLAYOUT, NFS4ERR_BADIOMODE,
>> NFS4ERR_DELEG_REVOKED and NFS4ERR_GRACE, so a synchronous LAYOUTCOMMIT
>> returns 0 for those.  A server that has revoked the layout answers
>> NFS4ERR_BADLAYOUT; once the client drops that layout its extent tree
>> goes with it, and fsync() and close() have returned 0 for data that
>> reads back as zeroes.
>>
>> When ext_tree_mark_committed() puts extents back, record -EIO in the
>> mapping's writeback error and the superblock's, and have
>> pnfs_generic_sync(), which only the block and SCSI layouts use, return
>> an error recorded during its LAYOUTCOMMIT.  The files and flexfiles
>> layouts, whose LAYOUTCOMMIT does not decide what a read of the file
>> returns, are unchanged.
>
> Looks good:
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
>
> Should pnfs_generic_sync move into the blocklayout code as that is
> the only user and it thus isn't exactly overly generic?

Yep, that can be done - I can do it on a v2 here.

Sashiko also found that I messed up the error handling - this doesn't
consume the error on the mapping, and I probably should switch this around
to something like:

errseq_t since = READ_ONCE(inode->i_mapping->wb_err);
...
return filemap_check_wb_err(inode->i_mapping, since);

That change will probably drop your R-b, unless you say otherwise.

Ben
