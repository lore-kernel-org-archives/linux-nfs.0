Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.175
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793642747;
	b=cIRyvj7eilmTygufFD3+Aoa6Opq2WFfQAHEOmtsg20j7tfJVJ9mkCMj0vsy/p4q6+fJW
	 fzAtelVVXQz7ZWVKGwg9Pge4bWzZfjNOiO7ph3eCIcto/+19tz1EPEAKCVL07oClxspAY
	 xLIgrOqMhzDbZEILjAerqC976wG/YDTaB1gYQgII5RZ8PULy7DLrQ+3AVz3KUqvopmNv+
	 uTQ8dpN+zVs5pbEekZQVqjtl7JPPo/c69nTU6yKRfwM5iXpvHesXXfW3a9fsVjN76gsf1
	 X4S234q0+KZmcW8Xhv0jw7u2PjKVbDWFoC1ifQpP54qm81mB9NrKxRrbo9Hu+AfPuyg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793642747;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Received:X-Forwarded-Encrypted:X-Received:MIME-Version:References:
	 In-Reply-To:From:Date:X-Gmail-Original-Message-ID:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type;
	bh=/vXXDZI2TLqXD/tqTZGHj/cF0YcMq0fXP1TpWYkM2ME=;
	b=hYGv9LoxD7HzlyJJ0cMQXys6sYPlRe4jBNubihYFMysVvt0m9yZ2PqA/RFc6aTtLqpBO
	 1Mkoa3PnFDzXgnM+sdnuv52sSlsrP8w3d4oYTuRKsm2f5up1nxbp2HIySM2JLossgZwKP
	 FuGYKA+S8xl2VcxVr836CVgDHoBPREtl3DIp5S9SkCOVCbodSZ4zxvouBSDZnepNqGxnv
	 khXE3Ot04kOa5aN0yLb7UTOus4xAMFf2hkuVTyMTbSiBxn11kJdIaSJBjm4F0KXZve5+h
	 HN4r4/4qyeeB3UwpwzlnqhfN2KFzfbJ9V3Oz+IzTGUcgfdUlPlGCg6bzZaumVafDfUQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=linux-foundation.org;
	spf=pass smtp.mailfrom=linuxfoundation.org;
	dkim=pass header.d=linux-foundation.org header.i=@linux-foundation.org header.a=rsa-sha256 header.s=google header.b=LHv5lhPl;
	arc=none smtp.remote-ip=209.85.208.175
Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com [209.85.208.175])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 33427606A59E
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 18:05:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 33427606A59E
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linuxfoundation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux-foundation.org header.i=@linux-foundation.org header.a=rsa-sha256 header.s=google header.b=LHv5lhPl
Received: by mail-lj1-f175.google.com with SMTP id 38308e7fff4ca-3ab3b29a210so35844751fa.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 10:05:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1793642745; x=1794247545; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=/vXXDZI2TLqXD/tqTZGHj/cF0YcMq0fXP1TpWYkM2ME=;
        b=LHv5lhPlC1UDFWlU2KUTe7W9GF2fDpbeX37JU1ESPU16Yy67j7656GZE/vpkwS0+Vy
         W0GknyOBRBqGq+dhV+aCeWpi8PXnwESQVgmQ4C28JyokaBvY4Ev2muW+kn4hohRMpeDm
         o1dzFEq7v3fAFC1rYPEKXpWBogK1GiONvOAwM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793642745; x=1794247545;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=/vXXDZI2TLqXD/tqTZGHj/cF0YcMq0fXP1TpWYkM2ME=;
        b=YY03gK61QimmGGB0lp6fL2GvlqDPcUYAp70sNXvcukV71TSPmwW6ChcEMZkWD7H734
         ACpIiPrNxxCrbk57ftXKaecDpRIgWXMLH/k4X6BRQVq9YD7/DOeqJfxugLimJe3MZpCE
         PHhyPi/C5mkj8ODHvbcTjPDMWsVuDMlBxnv3vKnfMR+YbT70BRYTHs9vggzU89GWU7Nt
         GbRNAF15y1vQ++hCunGw1ZSn1g1QFW1vppD9THi2qwXtAch35O88yMgJsfCQyWNsi0ve
         3cDUVk3+RmEYY7lc5DpY6oRJ0aHngGOHWeQJihuFFyxgwCNpPpJeS2+wpexbpQ0CSAO4
         +0lA==
X-Forwarded-Encrypted: i=1; AKwUvBxM/U3wkuOphDntvvSyJCF6ULC4qEj4SYqiI7AEgQEDHX/MlXNbQZyxJ3lrHdlyLdxWrhmG7KgOwxI=@vger.kernel.org
X-Gm-Message-State: APuU4Z9ufqFlP22TaVO/dMAJ9DG12c25/mUffbwutOCBXosnbqa3oI0/
	RpGa5/rX1sKzCdjQK2INC5szOViWl7Gj9KvvvaAHOWX1Ek9+WbAberPpgUXi/xG2nL2GfsTd9WQ
	qx6cbaH8pNA==
X-Gm-Gg: AYBFou2jdzKuasfwpE422MpgP4g5JEkeE00luuU2P4EAu8DeZYrBTojlIV6raG1acBs
	xUTZ/8rxmbxeRWqYkePUh6IDHouFcDzPvBGhonXpibVrCFGV5aRD8WOFmc1JZ9GPwHASDKS9Hn+
	zw8dgcuPS9RcvZuZksiGCZX29NBt8DFzJpD/ZCmamPJ7pK9LB0lc0oRDIAhleqVQt2buT52IrVo
	3gBjaTHZD/C/DykeX4aqP02Uhw4tq1PGL5kqfnOv3PbRlRZHafsLRj2rQ+FQOrFSsdR3LLxB5hC
	4Mt5+PdH9ht92yPAKwN3iXwE/ObfUao/lXC+j5vLMzTtYGdPwSQxMoaLCgvAK9w3p6adQHB0cTP
	UL3M+MV9JBEv6PYapkira5IJZOYYZOILC2Sj8yQJx9un39OZvCN+xA//ecQi/5f46JCcMxk26lA
	1jPSi7jE0DILbwA8J+FyhpSY3KTqfV6aYrGVY92pEplRWiQZVHteCXJ8LOZPrs5g6Eou4Sg5qPz
	lXXXS9pOGUoA73FggzTq7tfpryAs+HNg96WXiE4Oy7TAtAfM1/L6wzr0VMaIZBlVor02aVb45Hc
	QTmAnI1W+9vcUEY6MSlmobcH9OQJ7jIvvyFh54iy3A411J9Xs6fRKwz5qU8BzGI1fLmF7e5nB/o
	DDnFiVw==
X-Received: by 2002:a05:651c:1b8c:b0:3a9:d111:6520 with SMTP id 38308e7fff4ca-3aca55f2846mr31130951fa.0.1793642745338;
        Mon, 02 Nov 2026 10:05:45 -0800 (PST)
Received: from mail-lj1-f177.google.com (mail-lj1-f177.google.com. [209.85.208.177])
        by smtp.gmail.com with ESMTPSA id 38308e7fff4ca-3acd5c3c392sm863601fa.25.2026.11.02.10.05.45
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 02 Nov 2026 10:05:45 -0800 (PST)
Received: by mail-lj1-f177.google.com with SMTP id 38308e7fff4ca-3ab35e31f6dso36119381fa.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 10:05:45 -0800 (PST)
X-Forwarded-Encrypted: i=1; AKwUvBw6MRDH1T8bwbjjHAqXggQPtL+EZJfAKuYYWNnRAo+XWtWFSWXqlUsFBYXpJ7GxFATbVj0TW62b0Tk=@vger.kernel.org
X-Received: by 2002:a17:907:d94:b0:c2d:c80e:8366 with SMTP id
 a640c23a62f3a-c4ca7426f6emr874452266b.0.1793642348398; Mon, 02 Nov 2026
 09:59:08 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org> <20261102-work-procfs-bugfixes-v1-1-59422ed3e465@kernel.org>
In-Reply-To: <20261102-work-procfs-bugfixes-v1-1-59422ed3e465@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 2 Nov 2026 09:58:51 -0800
X-Gmail-Original-Message-ID: <CAHk-=wiSA7-mqmAjTQDaU7UjUyWt0TxYwXHafL8ZAPudy+B_uQ@mail.gmail.com>
X-Gm-Features: AclHuK_qZTBVsLQIdymgRHScSFenC6XsGggUDmcuOugjrSTbuVkeASUmC_hYPZo
Message-ID: <CAHk-=wiSA7-mqmAjTQDaU7UjUyWt0TxYwXHafL8ZAPudy+B_uQ@mail.gmail.com>
Subject: Re: [PATCH RFC 01/38] PCI/proc: don't truncate the position of config
 space accesses
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>, 
	Josef Bacik <josef@toxicpanda.com>, Chris Mason <mason@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Eric Dumazet <edumazet@kernel.org>, 
	Thomas Gleixner <tglx@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, 
	Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, Greg Kroah-Hartman <gregkh@suse.de>, 
	Joel Granados <joel.granados@kernel.org>, Kees Cook <kees@kernel.org>, Jan Kara <jack@suse.cz>, 
	Jan Kara <jack@suse.com>, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
	linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, 
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, ntfs3@lists.linux.dev, 
	platform-driver-x86@vger.kernel.org, coreteam@netfilter.org, 
	kexec@lists.infradead.org, linux-pci@vger.kernel.org, 
	linux-sound@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	dri-devel@lists.freedesktop.org, ibm-acpi-devel@lists.sourceforge.net, 
	jfs-discussion@lists.sourceforge.net, linux-alpha@vger.kernel.org, 
	linux-arm-kernel@lists.infradead.org, linux-cifs@vger.kernel.org, 
	linux-fbdev@vger.kernel.org, linux-hwmon@vger.kernel.org, linux-mm@kvack.org, 
	linux-sh@vger.kernel.org, linux-usb@vger.kernel.org, 
	samba-technical@lists.samba.org, sparclinux@vger.kernel.org, 
	linux-m68k@lists.linux-m68k.org, linux-doc@vger.kernel.org, 
	linux-serial@vger.kernel.org, linux-atm-general@lists.sourceforge.net, 
	Takashi Iwai <tiwai@suse.de>, linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
	linux-debuggers@vger.kernel.org, Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Mon, 2 Nov 2026 at 06:22, Christian Brauner <brauner@kernel.org> wrote:
>
> proc_bus_pci_write() truncates the file position to an int. A pwrite()
> at an offset like 0xfffff000 turns it negative [..]

I think this would actually be better with rw_verify_area() just
checking a per-file maxbytes.

We already have that logic for lseek and friends - using that fairly
hacky combination of s_maxbytes and !unsigned_offsets().

We should combine s_maxbytes and unsigned_offsets() at file open time
into f_maxbytes and check that not just at lseek but in
rw_verify_area.

And then things like proc_bus_pci could set it's size limit in one single place.

Hmm?

                   Linus
