Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793123715;
	b=sLohU1/46mo+INuxrU+56x05lYjyTDZ1yT4vCZ1HxR01e8YlT/6U2rX+VhOHtfCttkix
	 koiQ2JJVqJHrFlYixOzNkTy6bWuHgIACyeT+g8XlvQTAazfV4OXQ6pm/9FjbbP6gGwUvO
	 X7bngcK7T8uFY2tidJlQT6QCHo0grVgWN3vPGCh8N0/nKQMLuecH0QWNHuaYIqG9rMxKN
	 skrDXhbcuotC1yA79f5WM6xXqbhgQ4QIuApdSrsZfnIYTV7rZatf90TpAhB1iOOHhpl8k
	 IMvFNXYRusL6hVPa7YCRCNwU020lxpcnyljR37FK0ZbspTMnoy6spSxqysgXTNoA+sA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793123715;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=0mrx6dW9Zr+Dr9/qeyAc5RF2aw4BQ2JE9fRD0hY1390=;
	b=XRml/jXmzLGyO3oIkvX80BsiiQU+vIKq/tlVry/obUU0Jirz+mrRBK+LjpvYDvaL+NGE
	 CSxbEKBXWrAjfyKleogQhruH4qPHkesDlBAn8a/IDcz5SRYq1zaKjAmwR1fJH3uvnhJsL
	 zAao5tbpX4i5alX7UlvSVkTIeNiGjbo1p6FEvbayOfLmHavhR9Izy2GYWft3ux6C5/IaA
	 LOeOmFDADNeO3E7Ft9S9Ci2xGLkhzVNrCaU1Bmx8uGVYCtCHqFb6LFUXrW8Ecc/w2cR1o
	 80o9Pi9pwkOIWbkq6reqaFsNz2HpRaA35CIGK8BehrAL5Yi1xJfvvJ3LaXl1g9PtBlw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="mK/52XWT";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9AB74606A31A;
	Tue, 27 Oct 2026 17:55:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mK/52XWT
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BACA71F031E1;
	Tue, 27 Oct 2026 17:55:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793123715;
	bh=0mrx6dW9Zr+Dr9/qeyAc5RF2aw4BQ2JE9fRD0hY1390=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=mK/52XWT+LwA3pvGFxW6JdZ9O3EDLQtcz4nNydxwh6TNBvXIqLdcwI/Lm63QtjkW/
	 iwuDWHk1gcBfZE/2aMB76c2i8vCGsVmiJgS/fVek06Z7srY8ej6i/oFmIopagVJgbJ
	 6Ug3mj3B9yjduPG0wp9bHJwNvTHIwOsSePdSGu0oHrRj+ppl1cJjdfE+fxbk6/hbWw
	 jtt0eWsht0zH/CibsuZvwCcRppXkN3Os3DdrN0ujvUXRVMAVvC51+Kz6I6bIAS4fCO
	 huegC5Tp3Rvv2bgfxNOV55du+3aKEJDc/9ginRfIIGxcgDHJ56VAcklHJRzIP1XIK8
	 WHtLsLxsJE1rw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 175A7F40066;
	Tue, 27 Oct 2026 13:55:14 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 27 Oct 2026 13:55:14 -0400
X-ME-Sender: <xms:guXgaman8m8hgd29DBbfO0xquouuaF63VCxwrcbXwoKZtzKlluYRmA>
    <xme:guXgakO-TU7GF3RWMi2SuxdHIW2BSakqv4RSsr_F7E7Cw3tAlHicfGp5uQll4piAt
    m9fgfezxOGiF1dWOuJ-j1Q_dHM9Z1pemOtRk9zDXPmcSIWNg2G1Zgxp>
X-ME-Proxy-Cause: dmFkZTGI9CojnDj3sv0b6BqjhYlTeOZC/1LMQMQRhBfJPKZasjYu2smuB14iFup+QyVhIn
    +wRYv8QwDL/+DY62uEp8Q+HOnFHvD7rwE1l9eksvmCCsI6MmOKcQqna/q870xLkqA1Ivox
    VEz18a9f9mkn8pHpGVSzyCS3Fu+sct+aT+w/wTdTGQxM480eEce2U8LQSHx1zcWrPjsoyx
    U6j9qVJq5Z3KEqlMens3621XVw20guShzqM0pcSF8xC3AV2sy/5cfqeelO/euLCbHq3/Ey
    F/Cntis2al8fW0jTz22BY/upZy6F84TNqFPM0d5dbJouq7VKKh0wWGBi4fSypE2lZ+y5lA
    lEk6bUC8MvxfAPmQ9VDxp9Z0Xdwc20kz9yCsVQvwFBRz9GUHifCNXbOK3sXfiuTDqA6aBi
    5JXPeJlIzb5XvqTV199IbLjIoC9fDmhYMZkYT8rTFkxjQlb7bD7kdjsIVXAiTVHNTjdW6d
    tr4l/mAymjHZyldJmxlo24jP8UmPJTHsAra30DlAoG4olIsxMuw/fkUfsnyal9oGQNmBIV
    LQuiA9RlHfgmqeyUsYCB/KdfIbwCW0gdQQeDBja5OOSfUPYLA1o70g/bQGs+NJ5j7PzgCd
    hh+Znj1lKL9IelEXy+OeXTGoaMZh9nCFYLJx+1rfUea9VknCUYgBjyBM5KZQ
X-ME-Proxy: <xmx:guXgamK10hOP4AolDM0NxWIA6Y7v2MbUJktv-xtBRjWTXAxBGQoTDA>
    <xmx:guXgarWdPQh7eU8J71laT2bYi66VP1FkBwuUanqaM_PoliqAxlsLgw>
    <xmx:guXgarM8gC6qlZlKhJLl5s8-TYAgt4hwimjrlDGlCLTIvRsIRAKL9w>
    <xmx:guXganmx70fuW7hK34LZVofJFSq3Vjtp7qj7qud2PR95CHw6EMMscw>
    <xmx:guXgauUrz-o9CzS11td64alLhWrobzJFLayyZ_O0qTkIY0TH8ZpD3so4>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E806E782738; Tue, 27 Oct 2026 13:55:13 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AGB9D7c4hmNR
Date: Tue, 27 Oct 2026 13:54:53 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Jonathan Corbet" <corbet@lwn.net>, "Shuah Khan" <skhan@linuxfoundation.org>,
 "Randy Dunlap" <rdunlap@infradead.org>, "Mike Snitzer" <snitzer@kernel.org>,
 "Donald Hunter" <donald.hunter@gmail.com>,
 "Jakub Kicinski" <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@kernel.org>, "Paolo Abeni" <pabeni@redhat.com>,
 "Simon Horman" <horms@kernel.org>, "Steve Dickson" <steved@redhat.com>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-doc@vger.kernel.org
Message-Id: <ad5ac019-34ac-4c7f-8b90-cde8a0dc0546@slotpi15m67>
In-Reply-To: <20261027-export-iomode-v1-2-262ed932a036@kernel.org>
References: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
 <20261027-export-iomode-v1-2-262ed932a036@kernel.org>
Subject: Re: [PATCH 2/6] NFSD: Apply per-export I/O modes to READ and WRITE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/27/26 12:45 PM, Jeff Layton wrote:
> Resolve each export's effective I/O mode (explicit setting, else the
> global io_cache_read/write knob) in nfsd_iter_read and nfsd_vfs_write,
> and skip splice for reads on exports whose effective read mode is not
> buffered. Update the debugfs knob comments to match.

[ ... ]

> -	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp))
> +	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp) &&
> +	    nfsd_read_iomode(fhp->fh_export) == NFSD_IO_BUFFERED)
>  		err = nfsd_splice_read(rqstp, fhp, file, offset, count, eof);

nfsd_io_cache_read_set() still sets nfsd_disable_splice_read whenever
the global knob is switched to dontcache or direct, so
nfsd_read_splice_ok() returns false before this per-export test is
reached. An export pinned to riomode=buffered on such a server never
gets splice; it falls through to nfsd_iter_read() and does vector
buffered reads. The same applies to the splice_ok decisions in
nfsd4_encode_read() and nfsd4_encode_read_plus_data().

Patch 3/6 says an explicit per-export setting pins that export's
IO mode "regardless of the global knob", and that isn't quite true
now for the buffered case.

I need to think carefully about the interaction between the "disable
splice" setting, which is global, and the per-export I/O setting.

Separately, on the names of the export options: "riomode" and
"wiomode" are hard to read, and "mode" might suggest "permission bits"
to an administrator. How about read_io= and write_io= instead? They
follow the underscore style of the other multi-word export options
(no_subtree_check, root_squash, security_label) and read naturally:

  /srv/data  client(rw,read_io=direct,write_io=dontcache)

The values buffered, dontcache, and direct then carry the meaning
without "cache" or "mode" in the name.

The name appears in the exports syntax, the nfsd.export/content
output, the netlink YAML spec, and the forthcoming nfs-utils series,
so it's worth settling before v2 and before the nfs-utils side gets
merged.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
