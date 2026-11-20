Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795194975;
	b=J2Ex5Xs0A4uWeElcyMp835CbTRGxpQD6MCo8ZJqZNOHU58vJYrhmOZyF03wnbjMw1+mj
	 dpexEC2mPJqmZYo6zeZWCPaC/jBcwJisX94uuuy7wcHsI6Qu+3keRydoLYTLezFfFMIGo
	 OwYiFrfmWMuGzho2j+w1chd6Pdsdikl0uZL0/iiW2Wz03DhwP1DPVGHMrbId5VC8WBB6n
	 uExj5Q6DLru4htw/qQVhXUI7MPKDXhOc5HuBknhMujcVEoby6gws4QU9hFSrXe0/ySVpl
	 LzjBQHoXhNWn4D8uEHRiuWilo+QJodL4zfHaFBe+kL+OmKZeRKUjpDNX52REwRVbqdw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795194975;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=82gTsbSQPtusLywXkfGcZHRO/Ro6ePTh3uRyjt1y1a0=;
	b=BXBC8r8Fvce0RV6cre1alDwYDKNfbcPfhetfs42kPei2yh16zyAU2P2cZQ4jCwWXCZyq
	 /5/FP+3snDbsyat3761bGeuDDS/DiUP3aSGGQEyYJ7M/mEkNz8zEUQ+PW24ypWf22WJLO
	 6kLth0Ef6E3FBO0vzUSVIU6opShsthH2Ewr9wyId3+N7+Mhr3Qi1+aPJWp3jhD0YAtsfb
	 8cj9TO+eJc07orZvr+FyJOB+vuvdRsAKSqtGyw9WWM9Bj8zQ8Q+RRxJxSrZBwBIk2F4aw
	 NIiOEbHNEnW6/SiQvrh7H32oXRzkzAxJcsGV3WeBatTmnNetrQYY54wlgsaJM1I4J/w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QR9Fprfh;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3887B606A334;
	Fri, 20 Nov 2026 17:16:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QR9Fprfh
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E0C3F1F000CF;
	Fri, 20 Nov 2026 17:16:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795194974;
	bh=82gTsbSQPtusLywXkfGcZHRO/Ro6ePTh3uRyjt1y1a0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=QR9Fprfhw7IaX41El7ZnSQ8wUCsIGx7Vla8vSwaTRovCSpStq1UFjiXlrbH4mx8No
	 5tIcQ7Q15JYzCrx1VX4nju93vnoHT1N052p2x73mqDetfOZB/RwVu8saN42cbVxR7R
	 bOZnNn0ZPCts6jlwCN8oQ/o6mB85DIAs2bla6/xEogycwz1DSwUt9tqFZb6iYfLr0I
	 jq/6EPz77HDm7Gbh6vOZP10OkRua1R1xN0ipBXp1HlO1VekJ2qNOb0Ola73FdxK8fO
	 VkS8i8710Vc9pNYIS1oDPE9wSGDhTt7MJtBHWv0BMtWsWq4Y/W3pFxe/zirgQV6tXs
	 xyVzFc9RPNhJA==
Date: Fri, 20 Nov 2026 18:16:04 +0100
From: Christian Brauner <brauner@kernel.org>
To: Amir Goldstein <amir73il@gmail.com>, koraynilay <koray.fra@gmail.com>
Cc: Pali =?utf-8?B?Um9ow6Fy?= <pali@kernel.org>, 
	David Sterba <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>, 
	Sungjong Seo <sj1557.seo@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, Konstantin Komarov <almaz.alexandrovich@paragon-software.com>, 
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>, 
	Yuezhang Mo <yuezhang.mo@sony.com>, Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Ronnie Sahlberg <ronniesahlberg@gmail.com>, Shyam Prasad N <sprasad@microsoft.com>, 
	Bharath SM <bharathsm@microsoft.com>, Sergey Senozhatsky <senozhatsky@chromium.org>, 
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>, "Darrick J . Wong" <djwong@kernel.org>, 
	Sean Smith <defendthedisabled@gmail.com>, Andrey Albershteyn <aalbersh@kernel.org>, 
	Pedro Falcato <pfalcato@suse.de>, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, exfat@lists.linux.dev, ntfs3@lists.linux.dev, 
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-api@vger.kernel.org, 
	Theodore Tso <tytso@mit.edu>
Subject: Re: [RFC PATCH v4 00/10] add provenance time (ptime)
Message-ID: <20261120-geachtet-rathaus-mitstreiter-91c26d680a15@brauner>
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261118142613.be3r3s6kobkkxnz4@pali>
 <DMYFBDIV4Y08.35ZKR5G86U1H7@gmail.com>
 <20261118151605.lqtn5fz423kuswk5@pali>
 <DMYHPLWKPSH3.MUM1IIZZIWNR@gmail.com>
 <CAOQ4uxiwpdC-fKkqS5kiZ515q9MenC0jX4USV1idN7h2njx45Q@mail.gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAOQ4uxiwpdC-fKkqS5kiZ515q9MenC0jX4USV1idN7h2njx45Q@mail.gmail.com>

On Wed, Nov 18, 2026 at 06:28:04PM +0100, Amir Goldstein wrote:
> Shall we drop PTIME in favor of "is BTIME settable?" API?
> Leaving STATX_BTIME exactly as is.

Sounds fine to me.
