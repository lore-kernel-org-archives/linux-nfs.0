Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.170
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795102357;
	b=rogjxT3lId7IQWrDgVm/zdcAyeMuNVaaWyGsXi0+19qPFsnuVnUypzSJHrQiR1fYjCqF
	 5hzN3gSTQ++SLbRQ9UvU+zI1QOhmEd9M8CeZqLb4u/XqFxusGx9kjYS+5QMldZUNGcbBM
	 b5sHaR9OoNuXY3jt3GXblFseEe7r6IlHSXGFzt/W3eYv8L5Bh3nN++PfAE94++jacw9SE
	 kWWGtV7kzlteJl+6OQEuxxAwc8Riz0ZlxM2z8nBuZYiEYr3aLQvI7dXoi1/LKe7oM9Vf+
	 rcG6G13UtFzpDFS/SlWj2ruQiITW02eGfk35wcBMJTn0Iv/riyEOBiLBhW46+jOoSqQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795102357;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=f7T2TmAinoSSVrUkDLWCSHpGLO0VMoU6RTqJIGDHf8c=;
	b=vZ0rO6ubrZvOfzcAbfX+OYAMH6kt6oAAAgoPAiSKkRFkP4xRaPg7Ohz0nTTT30Ubvcid
	 b/e+tTo+O4TBaPJiH7Brbh2eWfcmcnNZWdAAd3pvn9Kt6fy7UU38TGnDctXkqZKW9geMZ
	 trahiDczlcGCDtxMNZhWzUJO1x1LpEYnNDZCEltbBiT2W0J/1vhqzKswli5bOSRMHhL4Q
	 vCs6qbk+TvX7oaXdzpDjTizJKNB079jpPEBmEL3SbooFk5kQfXsn4+y8KsuoMKz6vr3lS
	 DkH+t0uranVKOk1lhHcqIjQyjJ9VOsT6e8eq49WIDJ0o/NnqxNX4/pK21+XUBJiqC9w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=EriZpb1V;
	arc=none smtp.remote-ip=209.85.208.170
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com [209.85.208.170])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 529BF606A336
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 15:32:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 529BF606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=EriZpb1V
Received: by mail-lj1-f170.google.com with SMTP id 38308e7fff4ca-3ae25c9f857so24095881fa.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 07:32:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795102355; x=1795707155; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=f7T2TmAinoSSVrUkDLWCSHpGLO0VMoU6RTqJIGDHf8c=;
        b=EriZpb1V/2zno0fmMO54HL34Ty+nBUS/4UO0C6MvrvxZFEYE5Wk3AXr9C+UsTd1EKu
         e7VRl67WTxEo3VDt+hkZtLmFiEHnR1zJiLfC/Bq9BJKAFBDFohxqHF5Q1gg0wFZRWOaP
         GGmxEOrPJV8MRv3PkF03h/86SpZPKw+8KkyhjjjSRymeueMiKP4mQ8rtd0qNdqm/fzoE
         MNeg/d90yqGf1ngIGXcTcG1X2LenLIoGjIMBxdm9LKyp4bnMI848kU3NoOJqH9CbrAin
         fitPeVcUyIY+ve4q72M8iKNlPUyICj34RV6qW8QMN0CuPmRvl1c9rcr7e4C4EfPjdOm/
         0D9A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795102355; x=1795707155;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=f7T2TmAinoSSVrUkDLWCSHpGLO0VMoU6RTqJIGDHf8c=;
        b=u8350Ch41cKYj2RHufJQgdX1niMIB1sr5ZNm/MavbYv2Y9r59/3Owz6Y+OV7caVkvD
         we30tZw5XVuOYUhOCHqJ6eHrTHekFHvgLezpgM7L0HqIoecSpGc8BKleRRmL2fbkq2BH
         Dj7h18Fe8JZBrfBForwB3+UW21t8NT1HODSpUIYZk70Ze0dfkvIh8qzswx+m1uCgen2m
         S43+i1aW9bLIC77ROgUO6Uht37oBXqOxv/CjJkYWGXqNrTWUu/cop5iLYimGBTWw4gtS
         LKvQMcHZrlpPgadlMA/tRRISVuo7OZMlvvp/DIFmWT6QgoSHLT+BN9yNbm0r73Z7BayF
         vD6w==
X-Forwarded-Encrypted: i=1; AL+hErFQAaWqqppFyxQDSm4InAiN70axiXvaSUqS2yLnU9+74EhxLkmT6LhhxvGnudEk1Gmkq2plqMJlc60=@vger.kernel.org
X-Gm-Message-State: APuU4Z+7g0/E21REPRBLoqoqlyhMVoP1QGFb75c/IH94noy/jaHzsIBj
	wgaarDlcTsoxdhkAW9xbVB0WqqmIBKLgq1NcHim2c+S6Knz3fjYuD9mr
X-Gm-Gg: AZFdTZdUI9N88yDlIJQpkr29OGs5vXehpbeORL2fpo56przzpJKhlnOyqCWYqD0FFAZ
	p9dZK3rjGpR+X28d7ZAjKGcyx8SbZcSibVy/0/FTQ1S/XGu3PUCZIKH2LDEQn5aCYw72krRqgp4
	3DQN6m59DeFXIJCfZf99jXSTfMSg15JcxSmGw3ep8Ffk4yX0k7hhapUOQXsVYXKfH/DJ0DhOjDB
	r7JgUtcS1u+E1kb1MKJ5E8Lu8PINS/cWCmpxlhKUKp8v+0cZpvtNQXA8Oq49FaFXfDllfk22Lk1
	QmDdIqvkzY0rjPY0cmog0j7MhsWDs2Ev5mUktzBXPw0JMBvICq0ni8nQeTAQkQj4Y+U/0kn98nT
	DTlqrWSA5QJKt9Q0bRC8AS7uX5XmHnLizivgpKVf8j89lYXBREpPQxikS3IOYFwqi1eJ2cAUiw1
	E+oeT0huwP3fbMDUdPzC+bqF75r0DmJehHBv2KwOTGfChYt3Bzji5vuQJKBl3WMWWBjk9Rv809v
	Fd4VJppbZTCCRQ6Brorkf66xldoYLOQLj2p8WMRBuyFkhDz3jWpZDNog8MGd3Ek9pvQ0XgH8+3v
	Kxbos6uLUHrPLBMJeynbEBAB65xKU0KswL0+HqiERlCsnF0IC6jV+96T5XXLh6VvfwVZSfN/ps2
	IktgdK2AWBlu5wDD+UygcWMv5NDl0sd6toHsoX7wT2HNGv76HXvS5v4KAPsw=
X-Received: by 2002:a05:651c:a149:b0:3aa:ef31:e51e with SMTP id 38308e7fff4ca-3ae7fa644d5mr1204161fa.19.1795102355312;
        Thu, 19 Nov 2026 07:32:35 -0800 (PST)
Received: from Lauri-G-Pro-14-M4.intra.lakuz.com (n2vuxegwnwppvr5uhf9-1.v6.elisa-laajakaista.fi. [2001:99a:2ab:bb00:c16c:a39e:e605:54b5])
        by smtp.gmail.com with ESMTPSA id 38308e7fff4ca-3ae6ebe67e2sm11532121fa.33.2026.11.19.07.32.33
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Thu, 19 Nov 2026 07:32:33 -0800 (PST)
From: Lauri Gates <lauri.gates@gmail.com>
To: koraynilay <koray.fra@gmail.com>
Cc: Dave Chinner <dgc@kernel.org>,
	Christian Brauner <brauner@kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-xfs@vger.kernel.org,
	Carlos Maiolino <cem@kernel.org>,
	Christian Brauner <christian@brauner.io>,
	"Darrick J. Wong" <djwong@kernel.org>,
	linux-api@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	ocfs2-devel@lists.linux.dev,
	linux-nfs@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	Amir Goldstein <amir73il@gmail.com>
Subject: Re: Concurrent FIEMAP on reflinked files serialises on the AGF buffer lock
Date: Thu, 19 Nov 2026 17:32:22 +0200
Message-ID: <20261119153222.65195-1-lauri.gates@gmail.com>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <DMZ4VQ7SZ07T.29WMPQ0BQZGSS@gmail.com>
References: <DMZ4VQ7SZ07T.29WMPQ0BQZGSS@gmail.com>
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

On Thu, Nov 19, 2026 at 01:00PM +0200, koraynilay wrote:
> It doesn't seem like an FS_XFLAG_NOSHARED flag would touch this new
> change, but I thought it was worth pointing out, especially because this
> patch would also add FS_XFLAG_PROJID and a new FS_FILE_ATTR_XFLAGS_MASK
> to have a way to include both legacy and newly added xflags, so
> FS_XFLAG_NOSHARED would maybe also go there (correct me if I'm wrong).

Thanks, that is useful. I agree it would go there, whichever meaning
it ends up with: as a newly added flag its bit would be added to
FS_FILE_ATTR_XFLAGS_MASK next to FS_XFLAG_PROJID, since your
fileattr_to_file_attr() masks the value with it as well as the mask
bit.

Your mask also changes the question I asked Christian. With it, a
plain "may share" flag works the way stx_attributes_mask does: a
filesystem that sets the bit in fsx_xflags_mask answers, and one that
does not (btrfs today) reads as "not reported" rather than "not
shared". The inverted meaning was only there because file_attr had no
such mask.

One constraint for that case: the flag has to stay out of
FS_XFLAGS_MASK. As I read your fileattr_to_file_attr(), every bit in
FS_XFLAGS_MASK is reported as supported on every filesystem, so a
plain flag there would read as "supported, not shared" on btrfs.
Outside FS_XFLAGS_MASK the flag is also never seen through the legacy
FS_IOC_FSGETXATTR, which masks with FS_XFLAGS_MASK. That is fine,
since only file_getattr() needs to report it.

Christian, with this mask on the way, would you take a plain flag
(say FS_XFLAG_MAYSHARE, "may have extents shared with another file")
that filesystems advertise through fsx_xflags_mask? If so, I'll build
the RFC on top of koraynilay's series instead of using the inverted
FS_XFLAG_NOSHARED.

Thanks,
Lauri
