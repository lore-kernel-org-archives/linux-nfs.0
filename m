Received: from mail-wr1-f42.google.com (mail-wr1-f42.google.com [209.85.221.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF72E3E49C1
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 13:21:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787836875; cv=none; b=SjIr+IVKej2GiCx+v46mMSeVtnvxkM7n40WL1uoOotdN1naOhs/Y7xpQ/iRk5AfKMCrbJwf3XkehzcR+SwVr/rOaidQMYXIYqbDEbm2WdlfcqNE8SdvAZUTwI4iuUyZvz3TyIXCrAVSeTfAJwL0wP+9F7kf0MB7uJdjb2+ax8Zc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787836875; c=relaxed/simple;
	bh=otkzb/Utnj2sMsei3FnfsBOWIWU1kpxHJ467PHyBctQ=;
	h=MIME-Version:Content-Type:Subject:From:To:Cc:In-Reply-To:
	 References:Date:Message-Id; b=fCIMcWIIPk5fmR7Izt5612rqQnTJOhucuoJY3OsFz84HRpi8LCRGa9grbUXFEv7uv+g+0ZgnZdA1PWWn5F7LZez6mptpb+pnu7QO8hcoSEwFPts2oXBm/Fqvh6149wN1XnJIk+dSY8CnUI7j+ZMwzac441bc1lewdIdbbOxqRV4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NRan3pWL; arc=none smtp.client-ip=209.85.221.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NRan3pWL"
Received: by mail-wr1-f42.google.com with SMTP id ffacd0b85a97d-482e257a23aso1187902f8f.0
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 06:21:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787836854; x=1788441654; darn=vger.kernel.org;
        h=message-id:date:references:in-reply-to:cc:to:from:subject
         :content-transfer-encoding:content-type:mime-version:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=an9B2mofauJa0deNsX9pImK+/DE4Hcahi53KOOKUS84=;
        b=NRan3pWLwMB2lKKp71xWXGZSVmMoxcPdhn8hR1dir6BZ5CCqNwU+4YYiplwyGYqq6D
         rWQNtucNX3NS1HxGulAmsie9m9u3xRVoVW40DW7lCDnkNWNSu9p4SZqJ54ke+4/CId2k
         byh86msy4ftD4eYMngdxAYbxrPAEyN3+RsAbU0RlKKcawtHnz4rRQYcOUDsCcbFxwhLF
         zJcmBXbrwkfpzT6YHE1BEMKVsxwfLHvj6qxdNhbO5VzidREZhTZX3M7640FP+shhkQM6
         acbJjVa450B/PB9tmJe0BMXbGuGiRjqEo8JtjLIsglU5de2z4/iEWjbZAJSAtchEaZB4
         Kt/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787836854; x=1788441654;
        h=message-id:date:references:in-reply-to:cc:to:from:subject
         :content-transfer-encoding:content-type:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=an9B2mofauJa0deNsX9pImK+/DE4Hcahi53KOOKUS84=;
        b=kbZkoWsW+rdFK5KLA2e7MyaTMW8BswHH1J5KRD85YYk9P4U/TztXQuLv6FebXCIoBM
         jtFdYfHQCm0RDaDWTY6r7R7EHFuZwNtWQSEj8+kfNMpYABQNtE/nuejBtCPa+XrVsXZM
         L0CWVTGcs+3DXbPS0e65owzDXcPlYraQd5JVZY0Rt65fpnMDEp41vOMT7IzYS81ba3Yu
         rYbzy3oR9in4N1LP1sZ0/l++1PEA9DJk0X3bWcjDGUv5UFf21GRyqLQq11TfhYBi29p+
         Kmrwe1s+dGtJ+uQAG/2jd4CeVkduXXubsMpLh4Qbhp0aCO8a06D85Fna+unRKyR9OpTv
         bW6w==
X-Forwarded-Encrypted: i=1; AHgh+Rpst3+B9hWEu6n6cp8UlQM42e0fkX3zdRrBdSOyaQYqx6qODKzlSlNqDM90aqIT4GQL3KphDMVgI9o=@vger.kernel.org
X-Gm-Message-State: AFuF++krtZ7/cC/6MKeTg7OpdmUj/FGyUV1vr6luBjoe1vCP31pXSy11
	pGCjLfXQ2K5L+hN5grFgGQZVdo98jtqmmamvSOOhlVJwG8PgywyfzIni
X-Gm-Gg: AR+sD13UKZoggp2JSbXyTKAjuR2lkb3w3sIQwjEYnQx8+Si2SfzV7u+kxC+DvK+Kfwk
	gbBc4npe3PM9h1xnEfIf268HzudYs1xBejfF5TBmFCX0Zk+fkTgm/APQ7lYBBC0rajmMzybNy75
	+zmPaxESbcmYe8KSB2HgX5vEudzz7bjP8z0Txx2qIzn/a9iy6sxXOnHArJuKnUaEbbUj+k32bup
	exVa8K5/ipqKp2eM/KLufA53DturS5PJS6SS9ltPyCEVlkPcAY7Ehl5W+EnWJU7osxZ6UYN3Y/E
	FuaNGdpnd0qPXswdJE8hB0IwtiTJYy8CeKu/edpmivPp6qMZbHQhpbIU8C6MSiNvBcTG+aWiSTw
	g/RI8ZIH2c+9rIpmdNlWbVEI3OaOPK4aUiBR23ZHnrO/vQGFyDX3rwZKN0ffBYkpi+yiMq53tpk
	Dk/xZGa3fhu2Kg6a5FT15ka9Wl6SsIoee+3eSLLOqzVY39WAXKm1S8Vsw3R1E7/90xD22wXfk7g
	IjYblZ4pzbI3lvthM00Hn84FZK4Fw+CwYfqe3ivQV1BzAm1zzW1bKr1DMWyjSlKNg==
X-Received: by 2002:a05:6000:645:b0:482:dbe5:d12a with SMTP id ffacd0b85a97d-482e26d8217mr16473770f8f.9.1787836853991;
        Thu, 27 Aug 2026 06:20:53 -0700 (PDT)
Received: from valmpani.valmpani (ppp-94-67-69-196.home.otenet.gr. [94.67.69.196])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-482e28f6917sm8694744f8f.35.2026.08.27.06.20.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 27 Aug 2026 06:20:52 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] NFS: sysfs: fix use-after-free on delayed kobject
 release
From: Vasileios Almpanis <vasilisalmpanis@gmail.com>
To: Vasileios Almpanis <vasilisalmpanis@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Trond Myklebust <trond.myklebust@hammerspace.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <20260803-nfs-v1-1-034176dab4a3@gmail.com>
References: <20260803-nfs-v1-1-034176dab4a3@gmail.com>
Date: Thu, 27 Aug 2026 15:20:46 +0200
Message-Id: <178783684601.144167.6448011883318625857.b4-review@b4>
X-Mailer: b4 0.16.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1787836851; l=227;
 i=vasilisalmpanis@gmail.com; s=20260731; h=from:subject:message-id;
 bh=otkzb/Utnj2sMsei3FnfsBOWIWU1kpxHJ467PHyBctQ=;
 b=07QqWqTywTQBT2setq/Vuljo/tf5nYXP4Vo4M9MA0JDQCD7YDR6HLI9vwsTNint1WFTcGWKZv
 PXGpT0JfPAKBdzlYaA7Nu/F1YGa0sRKfJf3NHwyYZ/BfMqMBDqzypSj
X-Developer-Key: i=vasilisalmpanis@gmail.com; a=ed25519;
 pk=gn5Uo6yL8Tlpq5uATxA3nqoq+U8eWLRbjD+bOk0qSpU=

Hello everyone, just checking on this patch. It has received required
review. Is there anything else needed before it can be merged?

Kind regards,
Vasileios Almpanis

-- 
Vasileios Almpanis <vasilisalmpanis@gmail.com>
