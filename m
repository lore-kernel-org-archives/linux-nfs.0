Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794067831;
	b=bNxXRcSiB2KxYU6KuGyhC9en7XoDmWzzcR388479PW0tmUdI+RXMzPpDqNWFuhT2sKxn
	 dLWq5pmZUZ7k+aOtnIgKFa8BY0Ssf8PImSyremihV8AQ4F/jw71e0X3ttZCKWdaRyB0e7
	 24xda3EoCCMQbDkJ9Iw7drLUImHu1HFDSL58DQq+XezsZ8JM3zDgmR3k8o2biH6kmfLFl
	 YaUhTWbRCXr+r98GwPddMaTCs+1S1C70pTsY2s4chuqac9GVuCAhtm+txweFz8saksCgs
	 6ODSdgMtA2tO481B0bGMzf23loTkjhxfwdXLTRUHNGBgyT1eX9bzxyjL6CWG9rpwGVA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794067831;
	h=Received:DKIM-Signature:Date:From:To:CC:Subject:User-Agent:
	 In-Reply-To:References:Message-ID:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=yrl1fDgvB8SejpyA+O0u1vRjlm41/COeTHtKBCR1yZ8=;
	b=d47J0q+aIryhgPNg1v3RSp7XlziOAmnEFxpZGzixZr2xD77Okt9aKdWK7/U2EAw6Sxnd
	 gnVNkM6Ip3sqMV0NVxuRMglW5I3reCGX+RaBtzSHox0h37bC4Szlf+119hQPDqt7grncw
	 x4edcJjoLTU85MLqkeORDmWw3CSUjLgw1oD6p0hmhwwWSZLcoAvWsnITKhmfjmCkbrNmH
	 VkNzq88oXosfg6unlxHTOYHHQs4VoPyc0Vq0UWvkdyeEhtPDnDVyZEo/O9UUjjgV+zU28
	 2i7i0mUGA4YrXpwMUoPpM3WC8+qaDgMzwrY/U6APzyriQz5YvrhLoLlXJsx2N/4dUsQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DudqRbSQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98E27606A32C;
	Sat,  7 Nov 2026 16:10:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DudqRbSQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1758C1F0089F;
	Sat,  7 Nov 2026 16:10:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794067830;
	bh=yrl1fDgvB8SejpyA+O0u1vRjlm41/COeTHtKBCR1yZ8=;
	h=Date:From:To:CC:Subject:In-Reply-To:References;
	b=DudqRbSQXCpr6NhdcgkB28/OJ09fv/xb+ZGVAY2ZZcm0NtXYxKjH24XfLPv1YVH+1
	 N2Smc+eQQaJmUtmHSjIuIOHPbXtdHkwnaUWqwn18l1Zgme7MhVjd/tmwPXx2sHiZmJ
	 bVG7HcpDVP0TwBfdMqAH6zxIyHwUkaCeHOVhR2aYppt91bZLwCTiFYtodZA1aRzQhT
	 JFzXQc4CJvaSMHUeBSzyyst4sJaPobtuTL08pUib1PO2/6JKi1TR0Oc7vVJSOMiTRg
	 di9pOtOgBcjQKNqN/zgV0r2ojSo7IUXfYme+kVAZvSpJolvZJtmmOXjKLjiXPaiu1m
	 qPutBKIcKy2tg==
Date: Sat, 07 Nov 2026 08:10:28 -0800
From: Kees Cook <kees@kernel.org>
To: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
CC: Linus Torvalds <torvalds@linux-foundation.org>, Jann Horn <jannh@google.com>,
 Josef Bacik <josef@toxicpanda.com>, Chris Mason <mason@kernel.org>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 Eric Dumazet <edumazet@kernel.org>, Thomas Gleixner <tglx@kernel.org>,
 Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Christoph Hellwig <hch@lst.de>, Greg Kroah-Hartman <gregkh@suse.de>,
 Joel Granados <joel.granados@kernel.org>, Jan Kara <jack@suse.cz>,
 Jan Kara <jack@suse.com>, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-acpi@vger.kernel.org,
 linux-kselftest@vger.kernel.org, linux-s390@vger.kernel.org,
 linux-scsi@vger.kernel.org, linux-um@lists.infradead.org,
 linux-wireless@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 netdev@vger.kernel.org, ntfs3@lists.linux.dev,
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
 Takashi Iwai <tiwai@suse.de>, linux-input@vger.kernel.org,
 linux-raid@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-modules@vger.kernel.org, linux-debuggers@vger.kernel.org,
 "Christian Brauner (Amutable)" <brauner@kernel.org>,
 Chuck Lever <cel@kernel.org>
Subject: =?US-ASCII?Q?Re=3A_=5BPATCH_RESEND_v2_07/23=5D_proc=3A_let_pr?=
 =?US-ASCII?Q?ocfs_own_the_seq=5Ffile_of_seq=5Ffile_entries?=
User-Agent: K-9 Mail for Android
In-Reply-To: <20261104-work-procfs-core-v2-7-76ace653a773@kernel.org>
References: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org> <20261104-work-procfs-core-v2-7-76ace653a773@kernel.org>
Message-ID: <8A21EE2A-F392-40B7-9152-CBC440FDDA70@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable



On November 4, 2026 11:30:58 AM PST, Christian Brauner <brauner@kernel=2Eo=
rg> wrote:
> [=2E=2E=2E]
>+static int pde_init_seq_direct(struct proc_dir_entry *pde)
>+{
>+	struct seq_operations *ops;
>+
>+	if (!pde_is_seq_file(pde))
>+		return 0;
>+	ops =3D kmalloc(sizeof(*ops), GFP_KERNEL);

Please use the new style typed allocation calls for objects:

ops =3D kmalloc_obj(*ops);

(This happened to jump out at me, but please check the other patches for t=
his pattern=2E)

> 		dp->open =3D kzalloc(sizeof(*dp->open), GFP_KERNEL);

Same, etc=2E

--=20
Kees Cook
