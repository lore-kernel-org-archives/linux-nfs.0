Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.215.180
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795257356;
	b=NOIw8RifAfQvLDIupPAVWcZJohz3uJav7pUv7ckWA1iR21l+wIVsMvKu2yDrwcOC1S5W
	 Ae5St90v5timh3Bauf0lpiewFJlxQ9Sy3Twec2MpRpzeBqObYQOujj18ikhSV21SjGQsI
	 dyPBZ9Dukty5cCPXG3SSRHuC+fJm2pp9WoCVpdIFO2CPEuoFnjIwShYjDtL8zKIj3A2DA
	 c5Fuz/UaUtAPSTjnChOZTcpXWcd/Df1U77ydoyVTwUjCG6FK621zSvok7UEnbgZXMp7YL
	 78hSAX1VuyhS5rydHaKsNHtQW0dmsyBZ/Ss/niIKl7tO86ryAfGbaWPjJfBOevBQ0oQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795257356;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=AuBQKyEcSEqVjdsmPdKelR9xg5E9gpi6vzmfPVV2BCA=;
	b=NG5BuuLyhi6Y8BfwwY/CAdl052hn0u4i9x0WTTAq4Y2PwseNNzHEV4wDvCFH3AJHigIS
	 B2PoozKPPSZq7uOGQbNHlHZFUjGxgszFSF9EB4krXWT0c+A8hOHMGB3hypIT5JHSx4QWI
	 UOz9XV5qCSsO4dlkiLShcq8QjAAWxNILy146kEvMR0vc5oEDJ38YSW62aEmPZey/9cD9D
	 14FsTBa5pRC2/0LCpgKyzETfDG4D3PNTWG9zijqTGg8Ea3o2TQM+P30G70r6xmXLzQDL4
	 6LnWX+8ml41Jx6HhWq1fUrVg2ow6g6BUESyibW1mKbPeiBcxmhy9kDFlp+8AAbWR22Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Tr+NBNXp;
	arc=none smtp.remote-ip=209.85.215.180
Received: from mail-pg1-f180.google.com (mail-pg1-f180.google.com [209.85.215.180])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 934A6606A32A
	for <linux-nfs@vger.kernel.org>; Sat, 21 Nov 2026 10:35:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 934A6606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Tr+NBNXp
Received: by mail-pg1-f180.google.com with SMTP id 41be03b00d2f7-cdb684859cbso1029822a12.1
        for <linux-nfs@vger.kernel.org>; Sat, 21 Nov 2026 02:35:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795257356; x=1795862156; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=AuBQKyEcSEqVjdsmPdKelR9xg5E9gpi6vzmfPVV2BCA=;
        b=Tr+NBNXpqeLiTgO8OOS95eiW6ZcLshFYaEw4tZesYVbN1b78owj3WXV/5IVEfClE5S
         mfNIHd+RTW5kXFCJCKPypqrsBnM5yHIkmMFIEFR5ydUoblDZKW5+/1HQVpSzxPXpf2Ve
         FRv8MRoB4LwKEJ7DuWa1FCM8h3g40fh8NWaqbGHa20qnfNJ0Ic6Da4ggDAADwrs1V4Hg
         +RDGgJQADiRdU9LWqqzqFohNYAbwHD86z1/elgY4xGsjQOX2bNxNHYpo9fY5sNNgN3ya
         fbaKxq1O/RnMXLX4DR7Wt3jLlI9Muj9dZHAbhi3tEhHBSoQkimTvyhY3zEZNdu5/6c0q
         pDPw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795257356; x=1795862156;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=AuBQKyEcSEqVjdsmPdKelR9xg5E9gpi6vzmfPVV2BCA=;
        b=EARxQ48PgHVnDJAjgGLIGqX9xd9zDD4OMllhqKJZ4Kk4Ga6POpjcCawDrT5d94KLr+
         Dxm/CIbm1q2NA855iGrI1F8fSk+WSS03V04X9detcpH3CwQysTkooFGH3/Dpve1VV2cc
         y7G70vfzhv0nSUs6unsdli5nnWRs3ljMZg/Jd/+OA3M8YbsuqKxufYa/zfFO8kufyLgN
         +JzK+WwEwfZzWS5MolXnbUm1uU2a6n9t6Bep33Z26WHQ1dV5vRRqbbGD3JBOJ6lxx+ug
         7HcLnHTj+CZzS8wttDIJnsDuu7SEnjHPS9+Og9VIixzt3Y8b/9Gy+8W5ipcWO+fKQbCe
         9g3w==
X-Forwarded-Encrypted: i=1; AL+hErFYW7669wCwoiaxItTsTMvaQfoHdEY06z5ihP3kfU7up1JNnb5gvShusFSCgGinX3m/ZQoFlU4JwtY=@vger.kernel.org
X-Gm-Message-State: APuU4Z8oX0/AGNMh5M8Mq+HTzZNSH5Qbri2GxhZcNVXYNgsZrrMCNT7/
	RUP87FWLRBsX43TcGR6oYe9k5wSgC4wV+ZSPToZA/St17DvSn8IOBSJ6
X-Gm-Gg: AZFdTZfC4HKn60x1Dzx6LgBvtys5Xw2aBYWfU0gMcgU0LY0u/Cvb7l84T4yNSw9Mshm
	LP3WlalKJ2LjTai7OmGYsJLn5hk/l2AwfXY8v5yAmf7r4Pjry5v2xAvga/Jdc+xBH26HaGvm68A
	jT+JHnv28+EpY1FMQE3MiofO8icmycySMgpXW6ZuMkmVDTTSvxxk0hdMlfo5zQFzl83UkP8kpS9
	Kh7h8RmOquxtty3wrtU3sNI4y2a4A2XBBKc8ekUvEp20j/Z/zJVnlWiq+ukX/YnobRru6fXUX4p
	9IsQljKr+F6S4UM4NnEc+CHZnwIKFc/ybVTIdKtQWuVkMXS7yYutxOn2jibSdr/uk9wgTRPSOVY
	VaW1W/tIMv/BjMg6lnV08uapa8ccVMTkYRXPnued6GOUKMyM72ULn479r3N0vI9bqPbZEksbspy
	6sz8sPfY0oijl8eNM26D0A+nLTqHaURuWmzyJxA781CRsuGjqBTLyrYQfsQ2VjwGQe8K2sK0YaJ
	e6e5Ip8G6VkvS11tU0gcG6enU4YTnLqrxrl4iSHK3VMOaxdA3cvu60wMPif2a51zyzghE6v5xGo
	OzUP47+6nkJZo2ERWy6D+Q6C7v0Ci8ZJIuhRhE0IXYw=
X-Received: by 2002:a17:90b:1f87:b0:3b3:ca9e:9e22 with SMTP id 98e67ed59e1d1-3b41c9b2667mr5455682a91.17.1795257355893;
        Sat, 21 Nov 2026 02:35:55 -0800 (PST)
Received: from localhost.localdomain ([121.134.184.225])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3b44b7c6513sm1823681a91.4.2026.11.21.02.35.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 21 Nov 2026 02:35:55 -0800 (PST)
From: Unsung Lee <unsung0317@gmail.com>
To: Vasileios Almpanis <vasilisalmpanis@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Benjamin Coddington <bcodding@hammerspace.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFS: sysfs: fix use-after-free on delayed kobject release
Date: Sat, 21 Nov 2026 19:35:50 +0900
Message-Id: <20261121103550.1537739-1-unsung0317@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260803-nfs-v1-1-034176dab4a3@gmail.com>
References: <20260803-nfs-v1-1-034176dab4a3@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Mon, Aug 03, 2026, Vasileios Almpanis wrote:
> struct nfs_netns_client embeds two kobjects and is freed by
> nfs_netns_object_release(), the release function of nfs_net_kobj.
> Despite that the first one, p->kobject lives in the same allocation.
> Nothing keeps the allocation from being freed before p->kobject
> has been released.

[...]

I ran into the same KASAN report with CONFIG_DEBUG_KOBJECT_RELEASE=y:
a slab-use-after-free in __run_timers() on memory allocated by
nfs_netns_sysfs_setup() and freed by kobject_delayed_cleanup(), after
a network namespace was torn down.

Tested on v7.3.1 and v7.4-rc3 in a QEMU guest with KASAN, running
"for i in $(seq 16); do unshare -n true; done; sleep 20" after boot.
Without the patch, 3 of 3 boots hit the report on each kernel (on
v7.4-rc3 already during boot). With the patch, 10 boots on each kernel
gave no KASAN reports, and lockdep stayed enabled.

The test runs were automated with an LLM coding assistant.

Tested-by: Unsung Lee <unsung0317@gmail.com>
