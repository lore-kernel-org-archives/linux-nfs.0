Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.178
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794686757;
	b=pyE0ZUTIPFCrkXTVJa4zYmwNdNfRqAgojE6UGTXbT8d7JL1HDTMyyoTVyIT7V2vrwZKU
	 lFDlPHONHG0PWNvP63a4OK7kYzoIF06Ek0SBaIlDB+HM1rvrvGoFLCv/GuThGM4aOotRw
	 dbi6VK9qnpNAiFqLu9WtWK+4hzENKizNOZFcXsOV27dVbrpO7HzJhh8FtlDmy7a4X6ejZ
	 ifKcB/Uz9aq0xSsOSQ2rXWZ4j0PB+zb8dQH161MmKjadyXS6+FaLORrBjnOSXji9HBVzR
	 o4YggeE/u2glINHo5fNE8geCxFzjYYTBnKalPhs0Mn1ZajTWb6CN5C6T4XOqE/A3wFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794686757;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Date:From:To:Cc:Subject:In-Reply-To:References:MIME-Version:
	 Content-Type:Content-Disposition:Message-ID:User-Agent;
	bh=SncZUWGrBOxT9WurRufkDIe8hGFcWm37DANGybHY+fQ=;
	b=tuUu6xmjb/n899givQha8yJ+y01TPTyBKBesw7VvXYkmTFmkQC1+CRrJf+lmZxNgPdsa
	 lJCds0h9llOl8uQUI7vzPTCbxiP15yo912fHRYvrKHinkZhdj75TWVw+1eF4RmEacVGUr
	 tuagAwrxJr0YltneHMCtTCjkrOf36ow2zdZWfXZQnolPxlCI6QRD27cHN++V4S8HQmpUg
	 K6XeQUcHlTGLHbzdOJV7RcC1sOQI+K4Cre1F5StIUXG93J0xjYi05ioTs/UxPFWf+kHz4
	 Hcgdwaus+TAEgqsnl/tOttx/BNM5OxZrVz4dAzU+XPbQ6WtJGq9sSlWrytSfD1wnhsg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=chrisdown.name;
	spf=pass smtp.mailfrom=chrisdown.name;
	dkim=pass header.d=chrisdown.name header.i=@chrisdown.name header.a=rsa-sha256 header.s=google header.b=ZNpsvJMi;
	arc=none smtp.remote-ip=209.85.210.178
Received: from mail-pf1-f178.google.com (mail-pf1-f178.google.com [209.85.210.178])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A96F0606A339
	for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 20:05:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A96F0606A339
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=chrisdown.name
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=chrisdown.name
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.a=rsa-sha256 header.s=google header.b=ZNpsvJMi
Received: by mail-pf1-f178.google.com with SMTP id d2e1a72fcca58-8b271e573adso1161063b3a.2
        for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 12:05:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google; t=1794686756; x=1795291556; darn=vger.kernel.org;
        h=user-agent:message-id:content-disposition:content-type:mime-version
         :references:in-reply-to:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=SncZUWGrBOxT9WurRufkDIe8hGFcWm37DANGybHY+fQ=;
        b=ZNpsvJMizOoFFuviUq3R3I7xBszXKHR6f+dU2Lhp8+AdJOsuucW/Jpjz4DKxOc01P8
         7Bf2gXYBYorSyL2ypHSps7l13uEx7uOW/BQ3oCjgyM7fn4nszFId/ZhifmOhhkUhMak/
         Krv6vg2ZKrT882kZ97nfZeCj+rR5WiJ1p/wW0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794686756; x=1795291556;
        h=user-agent:message-id:content-disposition:content-type:mime-version
         :references:in-reply-to:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=SncZUWGrBOxT9WurRufkDIe8hGFcWm37DANGybHY+fQ=;
        b=13rihHjpUqC8+K7uFfSMauJRn4lYCp6pg6nkZ+SLMfUFhgbIuVAtsWYX3Ek6JSTPGX
         oU4OPx0ChdSsac4QwsdUuB7tABW4UDN2FKdwkMSMquER5k03MXQReoMxTmR6kZwu8Btk
         Y/52dl5ocHU/xqYykDNOXUpVOfA8Yznl3VNH+duo1b524tu14WcZ5Op96Hwr5Y9G8dFJ
         mjJs6A2CkPUtqLpvIruTUTW1qCnRP+9Uon+UJNpjed+d91Qn3c35MPxFupLxx5DyTBms
         hyGN7mRHOf+xJYEvyp3/NOvDgK8S4OBxeDznlPJK3ow6/ubz5JBK0OAR/PWxXtmSYdoz
         FjHg==
X-Forwarded-Encrypted: i=1; AL+hErFBFSBxIgEOHOrJ9tHF4BBKSWdHUHpAIuyrOFRKgfYefiKv+qZXVjiZT6LJSnNYeuBNGSxSQ2o76sM=@vger.kernel.org
X-Gm-Message-State: APuU4Z/hAvnhN9LB+/lV22mEkHCZA4dbLrdJt2Dpgjxx04GOQF1M74bG
	4G5Grw+/ZCiSS9h5PGeb9mxsfXHMoxM1QuTDj+rnGR+3OmM5ClM6upe0S60HL3TOhvQ=
X-Gm-Gg: AYBFou1S5oGPg7m4cmsob7nXMF5qVhnHULklj1NnmzekDF7BusSgVQu+vTj/rs4jgwU
	r0nC4IUmJaKxBlKQnpzeRHmgSuoDD7RJ1X25hkgv1gQZslnhj4juVXzNtdwP8rkZUjGyg8xL2n1
	HR+0L1dMOJYulcne91IAg0fHLIN5FV3g08OrAk70NB3zcgmpBUlYzhQCUPDYU/wiTkZaSEhheej
	+0DMTP3Amvzcf5/VN9nT/eQI9pyJyxwzzEiqsGCf0p7damXUsnE5wHpMsdnmBcMGKm4uu//V17d
	0qV3SZmJ8Fl7GBZkE/mFGAIAQ5MFgjLqdwzZ+b3Ae8x1Bd+ar+31FXqE2VC2lpgH2aocT0R1xpj
	xDicwxhiXHpUJvxcBDxOhLIluzSODUoKksUJrd90fVc61ytRyG++g3FxyLNWQ7wUxuOMXlkhO4T
	wBBHSYj1Acbx0qMmFhfIj036HG/0RNlkPuaaGPMEn9eubn7w3qNzv1ZwsVwgiSOgqTBIkQr1/FN
	KBwe+d0RnCUXozeuUfVYcuRYp7aB+gMEUQIKNttjNSSOo5FZ9/DHxvUW9Vi3MT2AYPi33zV0Y9j
	s8JuNklDCC135NyKdokmpj1PUICwBUTMdTKPQSChnU67nslJUvYPUxAoFCn+dOxL2iKg07rcfHS
	xv6bh0SM4xdiW9YmtzNyBuBQfYmuhwxa/STghrJYIGuvR+gc8l79Vsv3/11BwtEcpQDg8i/Koaq
	xNkORiMDq77z04/S2U/VkMhSCAdJPVULhhedxE6xa86KS2+J8jUZtYiQH8
X-Received: by 2002:a05:6a21:748b:b0:3e3:37ff:3795 with SMTP id adf61e73a8af0-3f7a4dbfbbfmr5517650637.7.1794686756009;
        Sat, 14 Nov 2026 12:05:56 -0800 (PST)
Received: from [172.22.0.2] ([64.16.22.130])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-8bed12a8172sm2271197b3a.13.2026.11.14.12.05.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 14 Nov 2026 12:05:54 -0800 (PST)
Date: Sat, 14 Nov 2026 12:05:50 -0800
From: Chris Down <chris@chrisdown.name>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>,
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-mm@kvack.org, bpf@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org,
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org,
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev,
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org,
	stable@vger.kernel.org, Alexander Mikhalitsyn <alex@amutable.com>,
	Breno Leitao <leitao@debian.org>, Casey Schaufler <casey@schaufler-ca.com>,
	Chuck Lever <cel@kernel.org>, Sashiko <sashiko-bot@kernel.org>
Subject: Re: [PATCH RFC v2 00/42] fs: don't use pseudo filesystem files as
	storage
In-Reply-To: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Message-ID: <20261114120550.0c9e73aa12a3072c@chrisdown.name>
User-Agent: Mutt/2.4.3 (cc9e3943) (2026-10-09)

Hi Christian,

Patches 1-11, 13-16, 18-26, 28, 31, 32, 34-37 and 39-42 look good to me,
so for those please feel free to add:

Reviewed-by: Chris Down <chris@chrisdown.name>

I've also tested 5, 6, 34-37, 41 and 42. The selftests all pass with the
series applied, and a uid 0 without capabilities can no longer change
/sys/kernel/reboot/mode through a loop device. So for those, please also
feel free to add:

Tested-by: Chris Down <chris@chrisdown.name>

I've replied separately to 17 and 33.

Thanks!

Chris
