Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795047920;
	b=P6LZoVeSOlJULpZuqrj9muOw+KMNQ1li6+SuGdDoppWGEmHkEVfX7hdP4SXEHjAtDLJS
	 HCL7KzIzosVkDhaziuBYtCEfr+l+rE5Z4PlijS56GnYTISSeHyETqjE0C+QpmlDh1+2zk
	 r5GUtenkE/Yah2hr30ro37hmjoeak5kqCGBWyj3jidE+5zw+ypBKZse0Epp6zsc7cgUBY
	 zF17Bfxv7s47WCOEovxS5E/WzzifanhM33lwRE/NtpM2zmP3lc1ZLsXFkg9fu5F0XWOCz
	 0DRQ5MXdLPMnuvCWLgxsIolkRVVgb2PwfsGRzTuyPZm3m7DbiQmqgjWpeLfOPQuCgqQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795047920;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=M4+iI66pVBP+4vibL3T75xrw5k3lOfdLMjtLDFVvV8g=;
	b=brHDYdNVsG/8EY/tQmpxe1+j/Rpv90HWVHZDmutUksE6d6ttpPwVgOr/fwnRW2ZUYqDW
	 xjohSzSBoMHMCKcJVWmRvuSIP/8hdmjrhBGzkO6zE+Ag3TDymGy5QdCqQVwjLfo3QwntN
	 aJBKcZUQujq/QFL7vUEHxBh1r+Q8pE6ubJ2dz/ASfSkv/MmwewiFK0BDxKIL/QmUT2lBD
	 gV7F6tOzLNW7yXx6xZVpAec+GBpk7301W2jjR3IRvon/3XtZMJ9Iw8EnHX45x7fk2gMex
	 yV2tCapih4giHh2Knsa5W3I1bEBm8PeCdJOxaz0QmVQaJLGKg5pI7Xy4kXNXQY5rHLQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=figiuMqN;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=cFVw0AE7;
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 53BF9606A32C
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 00:25:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 53BF9606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=figiuMqN;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=cFVw0AE7
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795047919;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=M4+iI66pVBP+4vibL3T75xrw5k3lOfdLMjtLDFVvV8g=;
	b=figiuMqNPSbJSC+rppKYW73jTrxg0F5RFlFTF8isncIxQMPE1WxN7Bn1FHZTvLkpofJq4d
	7m420J1xkEdKbn3Rcx5/MaC0RJqvUstWY08DU3pgmjHol80seQFiw6J/Lwkk9/s2t1SRbD
	9rIFexGnSFloom9KDpPKlHqDR/WtULw=
Received: from mail-yx1-f70.google.com (mail-yx1-f70.google.com
 [74.125.224.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-640-7ugsEUdONX-FmiQrMNmtXw-1; Wed, 18 Nov 2026 19:25:18 -0500
X-MC-Unique: 7ugsEUdONX-FmiQrMNmtXw-1
X-Mimecast-MFC-AGG-ID: 7ugsEUdONX-FmiQrMNmtXw_1795047918
Received: by mail-yx1-f70.google.com with SMTP id 956f58d0204a3-67c041acd09so2332017d50.3
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 16:25:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795047917; cv=none;
        d=google.com; s=arc-20260327;
        b=AO7xMnSvj5sYn4Et/2amWSfswWLEwWO/MqR0oUgBl0YRxD3UpeJSoOMmClEoIRk0Hm
         57vvPc8ivaS8H4iRArBj6ZzytnkwufacE1T0uvdItnj9YwYY8cUoTnnmeGl7dmVhEhvw
         Jtv+QbJxnBD/gPEi/WQ9anL3kPZ6YLgB9rjm/yH60pAjFNIPvSou40CbBmnko+ipZY7M
         4bZB8vUHZYEsVCD3cgTl79vlbv+p/45P+4wynKMrdK89eJa3Wtt0k8nPr5RDHaBBptMR
         aZ2se7WQd6WUcyVt6XrCOPnSBjNhHeNTbCg7DPUOcScmF/Bn1Ps/8c8G0K3PL3vnGkxb
         Nk9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=M4+iI66pVBP+4vibL3T75xrw5k3lOfdLMjtLDFVvV8g=;
        fh=ILr7decRYnK4wE8SxM8JKScRH1q7gAlTPx8UC14Zsjc=;
        b=e2vw8BS4+TMrpfoW6Lw7Qap2HMK3c8GPIkb1w0tmYl/SV+iw71nzdN1s+3YQf8od3v
         jVHEDPZLaTE1SEyR9IdiO0XeETgSBkNK+IJe8rk4mWjx6hZC8gPEz+VELUlswgNlhOXs
         p3b2bYc1BUfVUMiHh6B6gXxmaBgoQIvDr1uuxzwh+q/9MycV2whsETH5FtOrFNSNGk5s
         19+ZCLiuEtEC2jq7Cw3nEHbN4pj0VgzmezhX2hu75Y3L+x0fBmSE7RWrEv5GgitIJOX0
         VKo4RO01fwsPwDuOsetdy2fa1K9k5H/RaDFlyjRO5fWpGoQsJttS0tWJWU9r2ZjyMoK2
         q3Ow==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795047917; x=1795652717; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=M4+iI66pVBP+4vibL3T75xrw5k3lOfdLMjtLDFVvV8g=;
        b=cFVw0AE7k4Sx3klhOI+hIwBtN7pzKUDLCwxIvf1GwEfUyqXl+PBjIT0RRQORJGI2M5
         cr2BBRmZtSCGNDYE5TPt41nwQkXbpYRg+5nucbc1EyR77axD55D/rR3B9wEO/uO+mByo
         19pL3U/soO/odNlWuJH9T++t7gllhpBDYBkgbumJk/d3GIiLVhUTgGFX/u2cI2o7FltH
         /behdt6HVdhB8gjxhLqdWz+ZcLdeAisVvcqYEqfwiIRg9p2BYheknbhM2KU7DM5iRlJe
         R8KwC8LwBJEykAvLNnC6BIN3sAPeAHyzoBlzurMX0iFs/hlpJIP9XFKvRiilgYXmDhGt
         x1Dg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795047917; x=1795652717;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=M4+iI66pVBP+4vibL3T75xrw5k3lOfdLMjtLDFVvV8g=;
        b=NcEnmp6fSr8dm+7ifI6aaE7iOaXJ8sAK8AueLuXXVEh9ABaR+z4S12cqGxFpkFWC6N
         CIqw3efaY9SArYE144qBesJpagbL63Z99z4JcgNPcEgYto2NX3tvEFwLYNR4nfO+42tr
         SvzPBS9wi9Qo+AcgZ9N3wvsl6yXe01FtTeKkL4kFs4/qiVNciso+/0CAfsWtnIEOyrDG
         oSB9fPUNzGJEIoGJ/79G6TGrjr1q4LlSWCXIylJiOj/ip3r0dMlZ5cU8QTTDPzEptT/W
         ZlSrUvjx0oouvWj13Sov+RC8vn4KqDfSXRqVyggDdOoswd4R1OHB9qVO2Qs3B9DmDfoF
         I7Qw==
X-Forwarded-Encrypted: i=1; AL+hErHJJa6IaD2FHJLTxEZ/b0I1bkwHmpaJglxN30bzpAacELyg9kh880nGG4KzcpizcoaXffccSBX1CBI=@vger.kernel.org
X-Gm-Message-State: APuU4Z/Rc+S3o+15Z0tHD5md59ZwZMMdJD1yD2juhw+3a/BPBer9nac5
	4Ah4lfZ4gu0tQhXR3VzUUgsuEB/AYQ48K+EotBsTrnMii+6J97f8D1QgruTCJMqc6jeGJ8+dpfI
	E/PEnrz5pCL/YTaDNTf7hN8lm9bZK4foZJoFGHofHdb41k00bUECXhmMu2h+ACHC56IDvA/PV/I
	ASkWytlswzWimLmicGHr+S566/VhMpcZvCvdMY
X-Gm-Gg: AZFdTZfb2iz6OVQ0E8dEHrS6Vzdd0IeHROOToRO3XfG/bNzJTW6QRqaqCEl+gPoiP0f
	ltVVm4/trbLew0B8LxCSAQvMZ1QNSNZJOHeigqkttyaJZo8XMV60z5WHZw9qcJn+50UbX+xXWj9
	UVLh6PhWtDwX023oMvbK66wEBGlIBPK1+PYS7YDcShex6+UHwaAxXdWF7Nd0EuxGJlbYTZDowZR
	Rfp2nQwMv0ZBkK8yPfHfkNSEQQy4MCPISIXAprlNVeijA==
X-Received: by 2002:a05:690e:1553:20b0:67d:b309:a247 with SMTP id 956f58d0204a3-67dd3f89d1amr1300405d50.81.1795047917502;
        Wed, 18 Nov 2026 16:25:17 -0800 (PST)
X-Received: by 2002:a05:690e:1553:20b0:67d:b309:a247 with SMTP id
 956f58d0204a3-67dd3f89d1amr1300383d50.81.1795047916923; Wed, 18 Nov 2026
 16:25:16 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116171044.6938-1-jack@suse.cz> <20261118145941.1063127-21-jack@suse.cz>
In-Reply-To: <20261118145941.1063127-21-jack@suse.cz>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 19 Nov 2026 01:25:06 +0100
X-Gm-Features: AclHuK8SUbQZgISlLcenRaPXTNhazVJfuhMt4GCT6fjiABD73HgWRuB83sKw5Dc
Message-ID: <CAHc6FU7qgJ1R-bz2icUyQTQFs7_mKt=tat-ut66K-cgn-uet3Q@mail.gmail.com>
Subject: Re: [PATCH 08/13] fs: Provide inode_or_folios_dirty() helper
To: Jan Kara <jack@suse.cz>
Cc: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org, gfs2@lists.linux.dev, 
	Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, 
	Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, 
	Carlos Maiolino <cem@kernel.org>, linux-xfs@vger.kernel.org, 
	David Howells <dhowells@redhat.com>, Marc Dionne <marc.dionne@auristor.com>, 
	linux-afs@lists.infradead.org, Miklos Szeredi <miklos@szeredi.hu>, 
	fuse-devel@lists.linux.dev, linux-block@vger.kernel.org, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org, 
	Eric Biggers <ebiggers@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 18, 2026 at 4:00=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> Provide a helper function checking whether inode itself or some of its
> folios are dirty. We'll use it in filesystems instead of direct i_state
> checks. Note that this check returns true also if only timestamps are
> dirty when lazytime is enabled.

This is confusing. Can we just say this here?

"Also returns true when only the timestamps are dirty."

> This is what users really want.
>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/linux/fs.h | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 025f5d890689..f602deacf953 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2228,6 +2228,13 @@ static inline bool inode_is_dirty(struct inode *in=
ode, bool datasync)
>         return inode_state_read_once(inode) & mask;
>  }
>
> +/* Check whether anything in the inode itself or its folios need writing=
 */
> +static inline bool inode_or_folios_dirty(struct inode *inode)
> +{
> +       return inode_state_read_once(inode) & I_DIRTY_ALL ||
> +               mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY);
> +}
> +
>  static inline void set_inode_metadata_writeback(struct inode *inode)
>  {
>         spin_lock(&inode->i_lock);
> --
> 2.53.0
>

Thanks,
Andreas

