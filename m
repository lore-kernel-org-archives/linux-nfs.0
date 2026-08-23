Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5813226D4C3;
	Sun, 23 Aug 2026 16:21:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787502101; cv=none; b=Ms2FBfbJCsMOaqOi9TSL+zWiVkaenfAyvzaHTPOwyGfj+2gpmhdxF0TT3/XyaSgkoMuvNhCll6Vn/8po0jEo4SUzBrvITXP14kpSouPyTNVYl8ugRoYujuVnXQzf48gn94/dRmY55+HNqYh4PZ789/7YEYpDLweGXs3mF3uwVTw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787502101; c=relaxed/simple;
	bh=APHAnxuSU0LlEop2reWLsLdxUmu7dNgATlbOTdSNQs8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Ux9vj4IpQxeFreEVdumnJ2cns0OORMLgno+FpcrY/tj8K6hqtAkwfS9bF2jn5xeogdOgtrVoxCdB5GBVIX3iOQXOqaRVQF/hqUJRxafmhXtcPQlt06t27sIx4y1AXZnWhwVb6Bo4662s1Qwq6nqAbrH+wKvD6RgspLdEoem1zoA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Yam/4+VL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Yam/4+VL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 861BB1F000E9;
	Sun, 23 Aug 2026 16:21:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787502100;
	bh=RnSj+Bgd+3jBstqEGbuyMgqUBmxvmwddc2r8vS78EN8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Yam/4+VLgoOlGnUCj1nWaBn0mjIRcMfj5wRb2FXU24M2ae3ML0mvxfz5cX6/8iYjg
	 M1D1FXGvJojKyZwcM5Wbmn3wT4/nIqzsmaKDOllq0lkrJErQUIFh624Ld1P6dBM9Sd
	 /mKCbcOX4HNk3SvDhYPghc2FLD/+Lq50TXbPX2ezHerw7jIy097+bTOzpDeplPaSHd
	 H2DbLGFf8LTyGikFC2IJwKW8Yk0YQqFu0DWWlc51sKwsW4a8yBojt4lvnAZf5DIYxi
	 ogvf8HmFLZCNJ/9OT7FIKddD0ucd3/tORjOVns7YJNi9VKUVLmXKM2zzDDnRaOUTqX
	 83Qqm212Bj0iQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id BE1BBF40068;
	Sun, 23 Aug 2026 12:21:38 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 23 Aug 2026 12:21:38 -0400
X-ME-Sender: <xms:Eh6LausRmUFz0UJWY0txt6xh7T5UY7w7mzS2RMjrmta-ryoUXXbjDg>
    <xme:Eh6LauSWeJ5GMl24mCNYqSD9GNBNeU0glC8dmg8iME3TlaZB_FIs6-UgoR48F9qN8
    ZJvcnDXnctbOfv8mxNaP8O9cB5ziJBW6TPgrA7i7ZjQxAwwj6nCRCE>
X-ME-Proxy-Cause: dmFkZTFZPZzGjOnFRSeRyf3JaiZ4OyG+J7i4q5L/Lw8A0EtbuN4zmwIYyozc3VW6RdibUZ
    56uROk7F6Ybh9FuwnoSFSFYzKhZlnHi0hBKQWMpmHXcxTknbZ0NRkPmZeM+lYGBTiOWi38
    hlKdtWbt6V+0iqtR41eQ8h4aaI8ylpXf1FKqBvW8w+oejmbtnOcL3eqha4+Rwevai8YZj7
    NKKgMKWxa4ObtmEsq65/G4zDxLoc7+WANalviazufnZGj2ZHBeG+r4gB9ePyDFDjy9zfEy
    zEbMV4GNGaO/iz9Y939b3mWZ+ri0FX6xcpO7yvqXfI0CHR53RJBgCamzart2zkmX6G9gM5
    vgj8Jym14N2J15o8Y+7t76JyVic75SrmJ4Mbnn742K0LrmyMk1uyq5GfqUHNpMQWebznlS
    qlXuMp4b7gM2x3mqOruGxG+0i995L3r/yCmyjcLgSKw3I9cmlxp9UPtqsrf/LdGw8/4cli
    SxBFcvcyRPZkMExYW4s1jkN//LFXrPsYzqElQvKO7AfMUusTrOqVJNHYqjvct3HA+E8rgc
    wLgaCUkKFl1ut8fHtu4kJyw3JH5b9IbP0gEkDVof94tu2xhq3XA1OZwLNmwmbEDd4kQ4ia
    GJKxflv3uf4J0VTJw7+cAKFhb2XTD8L60yQ9xYB5LtVKdOxYSgUEOkTmJ8DA
X-ME-Proxy: <xmx:Eh6Lah8t5tO5VtDsuUW802dmdR3LMzGr2coK37tQuJeSW5RQEjDM5w>
    <xmx:Eh6LapYD5R2_h9wZsn9VwPt_2iQ8M4QUelFBAVZL7XYJB0FmVUUxHg>
    <xmx:Eh6LanqYeqWWLtPexkQmIEwpaVFpF32KWs9yKnKbKXRjGOvUSHe4mQ>
    <xmx:Eh6Lam3PKCfyspW2OFhbDlRkvLXrd0vUSh2RyC9msEKzY7M7Af-6RA>
    <xmx:Eh6LannHojT__aRyaByOgJD__IBaNE04o3iifCwtIDwQGp6dkn2aMo2X>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 9DC4A7811F0; Sun, 23 Aug 2026 12:21:38 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AJDur_V_LH-R
Date: Sun, 23 Aug 2026 12:21:19 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Amir Goldstein" <amir73il@gmail.com>
Cc: "Christoph Hellwig" <hch@infradead.org>,
 "Ameer Hamza" <ameer.hamza@truenas.com>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 "Jan Kara" <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>,
 "Christian Brauner" <brauner@kernel.org>
Message-Id: <5fb0315d-636c-44ff-8dcc-b4403e3be7c3@app.fastmail.com>
In-Reply-To: 
 <CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com>
References: <20260818225715.572140-1-ameer.hamza@truenas.com>
 <aoVHBkmPNSRakbYW@infradead.org>
 <9ad95194-983d-427d-9a07-c9eb0891d1a0@app.fastmail.com>
 <CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSD: Fix duplicate fsnotify access events for iterator READs
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sat, Aug 22, 2026, at 6:21 AM, Amir Goldstein wrote:
> (1) In this series
> https://lore.kernel.org/linux-fsdevel/20231122122715.2561213-1-amir73il@gmail.com/
> we intentionally moved the permission hook outside
> of the splice iterators because we wanted to avoid calling them
> with freeze protection held and also there were some duplicate calls
> for this work.
>
> At this point in time, the fsnotify_{access,modify} post hooks are
> usually called
> from the same context as the matching permission/security hooks.
> It doesn't have to be this way, but it's a good mental model IMO.
>
> (2) emitting many READ events from an iterator instead of one event for
> the user's READ request is more noisy and serves no purpose to users.
> In most cases (but not always) those events could be merged, but at the
> cost of futile CPU cycles.
>
> From a quick inspection of the code, it looks like:
> - fsnotify_access() is missing in vfs_splice_read()
> - the naming convention for splice_ do_splice_ vfs_splice_ is a horror
> - we could make the low level splice_direct_to_actor() static and possibly
>   rename it to splice_direct_to_actor_sd() or something
> - we could export vfs_splice_direct_to_actor() for nfsd which wraps
>   splice_direct_to_actor() with permission hook and fsnotify_access

IIUC this last bullet seems like clean layering to me. Do
you want to propose a patch or shall I?


-- 
Chuck Lever
