Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8BD6E218EBA;
	Wed, 19 Aug 2026 14:04:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787148255; cv=none; b=hBZfl9soeHYfk0TTGgK4FUYh5KmeN/pWy2Vw/mf8qcX+hC6FnISpifUH6fPSsv6xBpK2kf18BanPVONxBBj3KZHUGr3uLwvrtghlxOWq2cQDX48eUbRHuFe7rRhA0EfpmlZuLrIxFziMy6bwzZxRtNHBoHgX9RoDcUdT1cBy6YA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787148255; c=relaxed/simple;
	bh=apNDhRbFmnn/yiT59xWfw8j8bzTaI20K1rB8aI+kddE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=kwJ6qybCJClg8OcAAm5DukdcG7yJBUuvyp4KQR52uX/C68Jw6JUlYwJfgB9iw4/Mf8NsBVCmz+AqCA7kB0elteQhgtqU3nGA+GIFPugUs2aYj2FTgLfluo9R/JijEoe8zZ4VMDFHaWaXKCBe4EcMdA9f7OUsfGA4cvdntRDC7Wg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MQhQSCvT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MQhQSCvT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A5E171F00A3D;
	Wed, 19 Aug 2026 14:04:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787148254;
	bh=fnm64RRHDG1XXLHpu0c3nVTM4iXCvZV71B5QXHfkl+g=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=MQhQSCvTQ3mexEgEg6z4YgcgEbp1IUh+lUDE0TEIvEv6LwU5bt2aSeeRWGEamH5zm
	 NB6FsfscSg9MMOChXm20yMb7VvkDKwFM/kODQ7o/uVv1Cie2OI+SV6qgS45GZyB63L
	 w4hhzxlXJcoXyhEmNW2DcKVeptxxFJogeBkD/PsD2/WcBlXGIyK9ZECai/OXI2NRbf
	 tLtodlEDjaxXtcBiwmDABFVhfkSBUCP3TMsDIQqwPTieRktOVYerulOWKfUyB6k3RH
	 Jb6R4SBtlX+9LPkkPDu6qVvqkiKEup5krIxxtqpFme8lxAfd3p97UNVluygXNHJcJl
	 isX8tn1EJ5b7Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id D3EF0F40067;
	Wed, 19 Aug 2026 10:04:12 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 19 Aug 2026 10:04:12 -0400
X-ME-Sender: <xms:3LeFaptO8nAng0f2zcT0HmbkzSFgObYnpJSVNcg3SMPFF78m0Z4uOA>
    <xme:3LeFatSNPYZtvv1Yu8bzm8FnY86A6O19AqqLANH1mSQTqIdKmYHSw1ci52jvXcj_A
    5jvSdCHsXlvOsuHnU6cOdvJG0Qy-HPPzG9bNTsy_JpZVh8DwFeKEcQ>
X-ME-Proxy-Cause: dmFkZTEpi8Uljpi3TTVM2Qg4xk+Abm/RegXcZKumuRdbNTksiE3AmuXkQzzJ6sQ5N6Vk+8
    KqsMf/VbyMkCNHmTc/ea5kLu7S8Z2syohPHWBniXPW/cMrHfuF0hXtr3l47UvWV5cmtyJ7
    nchrHfKGNOMe/9diqUBpJSb7WqFKrtpudEwyg8QpHjp/ZTKjThq7jtY+/+ZHh1jkFK/VDu
    iN/ulDeggbuQjmIcxg/y2u5Ij/uWjpu6NDZov5fdwzDl23bJe5AOw09aQf2YENY4UhSHgE
    jPnatJrZLJNCCeZ087dk2kZrl7f/Xdm1MxmYB3zFLr3g3hmQm+ixRO1OWbbrWrtwrycAZp
    gc5NnqVwa37ZRRIIZZQjC+uOHsJUOSzsH8bU9zDDEv6AMXNhmszraAPIBCUyWiAzwdO0sZ
    Tya8pOkpphPKRC8n5E9rRQOVmqOYhcRjBOk34/XhRq9apRE57Jc/voqoc7xz7Bs56X3E0g
    El68TKPSayMCgYibPDkkRdvcoDji+A9WPk4jGMf8WtPT5ANmGT5pOOkXszdGm+DXYnGSps
    VM62rWdQ1OVZz72aevSlqnxP8FzewSQ5WJI1iXEVez0kmXDnlMwS6IrL1A28VYjgjKbTL6
    cdrzco2u6FlDH/2iHTdxEZvTmKJ4TAk3r0Rsjt0fLpdWBK5lBSnar8imeXXw
X-ME-Proxy: <xmx:3LeFatQWUgd4hpsZpjP4txGi0jEpVhTSFnO4S5xBMFDvFZbwY9jfQw>
    <xmx:3LeFaioDy7iGXMFuPj4LniY7CkgjVY2H4AbnJSFRtV7exdwnlAp3yg>
    <xmx:3LeFav0vyzn3k70T-dX2BUIVRHaxvAWQ0xioxpNC3iW_p6H95w0WBw>
    <xmx:3LeFap4nDom8iq2cegsfx_bKS6MJKZdoU0FzC5z4gjmxIKFq34_mgA>
    <xmx:3LeFarQLmGSvvfoje4Mvb1dlzZexaV65iIf49Sk82fNRZCb_DGuSr_Uh>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id AEBA37811F0; Wed, 19 Aug 2026 10:04:12 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AJDur_V_LH-R
Date: Wed, 19 Aug 2026 10:03:52 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Christoph Hellwig" <hch@infradead.org>,
 "Ameer Hamza" <ameer.hamza@truenas.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Jan Kara" <jack@suse.cz>,
 "Amir Goldstein" <amir73il@gmail.com>
Message-Id: <9ad95194-983d-427d-9a07-c9eb0891d1a0@app.fastmail.com>
In-Reply-To: <aoVHBkmPNSRakbYW@infradead.org>
References: <20260818225715.572140-1-ameer.hamza@truenas.com>
 <aoVHBkmPNSRakbYW@infradead.org>
Subject: Re: [PATCH 1/2] NFSD: Fix duplicate fsnotify access events for iterator READs
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Aug 19, 2026, at 2:02 AM, Christoph Hellwig wrote:
> Well, that is the underlying bug here.  ->splice_read should not                                                                       
> skip fsnotify events and nfsd should not work around this as
> fsnotify is not the business of the users of VFS APIs.

I asked for the duplicate event to be split out of Ameer's larger
series as a backportable fix because there is clearly a bug here.
But NFSD might not be the correct place to address it.

Today the fsnotify event comes from the system call implementations,
not from the splice helpers. do_sendfile() calls fsnotify_access()
once do_splice_direct() returns, and do_splice() does the same for
splice(2), while vfs_splice_read() and splice_direct_to_actor()
emit nothing. vfs_iocb_iter_read() is the outlier, emitting from
inside the helper.

NFSD calls splice_direct_to_actor() directly, so on that path it
acts like do_sendfile() and emits the event itself. That is why
the fsnotify event counts differ between NFSD's two read paths.
Moving the fsnotify call site down into ->splice_read would double
up sendfile events unless the system call implementations stop
emitting it at the same time.

Jan, Amir, what are your thoughts?

-- 
Chuck Lever
