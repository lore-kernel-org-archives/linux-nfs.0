Received: from mail-oo1-f52.google.com (mail-oo1-f52.google.com [209.85.161.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 838154399DC
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 13:14:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791810886; cv=none; b=KXQB+7I5x8NTYJRY6886U6FMrgDhfNYYdsNma5Kh4H5e1AJmT8SFQFVPbDqSF1S+amBWp830qPcMHJEM58MaVweMoYspmy3uZsNYtUcEw/ndJQKOw+spKlFnU0VT/tAsalgXx0dsf+7S4VHYs34s7W5qv1zAjieaC/SKXT0ODYQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791810886; c=relaxed/simple;
	bh=sDGPqLnbtD+WzSCkylGXnO67YQBDTEWpdxFzXZDFL04=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=GnJgt1v058iX9/l+8JRZX47FlTYXtQpJPkT8c/wtBA5guAoYTto4br43dy+WeyCsCg3j56DanGneuJyEsSV0ZIiK/QgM/soqf7EJLzXoceN0Lh6nfK0OSdnHiT1GpbwS1dXMWMmdNM36TaYfLnqOtPXwSnT/TLRJNsfaR1F56oQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=p24oVzkW; arc=none smtp.client-ip=209.85.161.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="p24oVzkW"
Received: by mail-oo1-f52.google.com with SMTP id 006d021491bc7-6cfb1329979so1252422eaf.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 06:14:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791810884; x=1792415684; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=sDGPqLnbtD+WzSCkylGXnO67YQBDTEWpdxFzXZDFL04=;
        b=p24oVzkWtpu7jCET9hvM8iEboLtGOPXt0zzHPxlvsUQ9Ijt5FDmL9E+dk3J6vRzmjo
         zprudbVipuMiNuNejJkRpXGfAxEvZqUSoVI1M1IoHJjXNH8way0RPSRLgKFIR36LBRMk
         aCYfdDZTy3c3KQV+D7s+8j9dLBnW/KWE0HAahdlMOeTamTVnmhu8L9db0FFParZHtwBM
         ehT7HP+yt92Mwz7I2N1YIrhoAEYSxPMpuKCgE/zYOHzK5zK1AS56L2xgD7KsMR01Cqs+
         n0NWDuaiVdlMwBJFJu5kYWDKookQzxLV+kSeZkalMYWpWT1mGOv1pW4cCBv+Ok93NKXD
         +Qbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791810884; x=1792415684;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=sDGPqLnbtD+WzSCkylGXnO67YQBDTEWpdxFzXZDFL04=;
        b=kdRe/oMQPugnuHJV2eNfDQKpXDBMrVzh8dEtpdSj66xA1IQeW9rOgqkFApr0TWMQCi
         SK2JokO+TvE9hjnd4Upb5re+UWZepG/TQQRcIhYp37TLJIZ00BFTPnsdq5Wluesm+m9/
         L1rwoMjmZUuHEN11/tyF0/NGfHNyxH4+R9chn0bZUylnpvht0LxTRS7Z3jaXFkprdv7+
         d1rEOq4qspo2VbxiSCEcPq0Q3+fzvvRUlO0QvMOR+8ypC4Azwh9s9h2J+G7+6qqSv35Y
         kelfzxCP3UuCW37Tezy32tLGZo49cdoLDPw8ARqko7/7NJ/xLw0sJqo4mVd+4ZFVn0qU
         aI/w==
X-Gm-Message-State: AFq9FYIvfBVcc1MNx7RXi037ZOfaj2jvjX+9ZFYUIjqgsghCBB79houF
	s4eOQhmY2hGlCVPXTRSuWHAMneWD6wE/h0l3/KAV3o+pq9vG2e6QZQP2yTaBQt4dKEZseqX3Czf
	3PHTS
X-Gm-Gg: AYBFou1ZSnZsYiKoPFPmnj5tDUTVQJ3uvL8E0cYK6Byf3eQZOkJcIhXGg/vH00H+SC4
	ZXKwshCh4rpS/v2+wGjUbBuBcLBUa+mPXfHiGnUiNNvAERBEMw12IxipdPyRZGyQy7F1MO3EszK
	Qk9IVjmrHcuQQU8lbp+6JSbniz2E0WNy9GJOxSoUFGzTJjz2U3KKtrQ2e1SQYiV5Q/MKc1uICLf
	ANdV27f0vI2Lx4RCKTt8I45TLFpiBuwlDoYUFM4m3pALBtNY97O2cl2hDvsJMExo3yN1UrQDldd
	HYG0c1PC3TVXfwCdXyHvJEZ5xi9W2zHue9KlfA9ypXjqMRvvpogJNh3ttI//YYlY9C19QBK2bUU
	iSu1IcXSTDLfXwexRlxuMbK4jUROIWB0/JOFOVs9YqpfwAZ1fKaS2InlWt+Fgb0ExaMu283qH9c
	KjwPwbTcnyJXNwfqP+sJ39kQYd8bStdMp7k6kyytv5x2N4WeyYaiXAitpIMgL6is4dpYjVKvUns
	RS+qssuQcw7BYSdnwOmASWDUvhh
X-Received: by 2002:a05:6820:1a08:b0:6de:d2c1:e97d with SMTP id 006d021491bc7-6ef12206f31mr7503183eaf.66.1791810884311;
        Mon, 12 Oct 2026 06:14:44 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-6f6d6796c54sm1866357eaf.2.2026.10.12.06.14.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 12 Oct 2026 06:14:43 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com
Subject: Re: [PATCH 0/3] NFS: Modernize decoding uint32 arrays
Date: Mon, 12 Oct 2026 09:14:41 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <5148DFB4-A99D-4044-A6BE-B41EC7E08538@hammerspace.com>
In-Reply-To: <20261012123346.123126-1-anna@kernel.org>
References: <20261012123346.123126-1-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 12 Oct 2026, at 8:33, Anna Schumaker wrote:

> From: Anna Schumaker <anna.schumaker@hammerspace.com>
>
> We've had several reports over the last few months people have tried to
> add bounds checking to the various places that need to decode a uint32
> array. None of them update the callsites to use
> xdr_stream_decode_uint32_array(), which has all the proper bounds
> checking already implemented. These patches make that change.
>
> Thoughts?

I like it - even if a little disappointed that you didn't state "malicious
server" anywhere.

Ben
