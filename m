Received: from mail-qt1-f178.google.com (mail-qt1-f178.google.com [209.85.160.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 605D042E412
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 13:49:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.178
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787579395; cv=pass; b=fxf6MOJIibDb4UhK9hwrotDBy/eUMb//8pTFmiARXPSpFtSH1nVHsCdM9f3Hs5L3IpXXiYG2zaqsKznliJCNP0MEfsQEIxTCEeaMsh07iLYaNtmQo665QzYFrN0c/KGatNI2gV7dqLzmr6AIpX6sSFAaehq1K2B7cc8IGUxQzq0=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787579395; c=relaxed/simple;
	bh=Gdi0w031Cj+0ZM8jnslnu596yibLYY4OhKTpyU6L/3w=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=gBAudtPsquBjmlmrT2iyKWIXcC3FUaLzZRh5AtiGAHayt8/B6Arm+ufmgKlCfmKiXHmjprzy5OxQvENg27+5QtYf21uaIBfVinLfdBiDCk5xlAfDxcBe3LvUkZL7bBEJkW8FM93Y+8dWwZIMe9ZXrVG8GUpzEp5ORuSmPaFqKc8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu; spf=pass smtp.mailfrom=szeredi.hu; dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b=NDMoFzvQ; arc=pass smtp.client-ip=209.85.160.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="NDMoFzvQ"
Received: by mail-qt1-f178.google.com with SMTP id d75a77b69052e-51c2a76536bso38075641cf.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 06:49:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787579392; cv=none;
        d=google.com; s=arc-20260327;
        b=pyIcuISWDcKty/uXS7jvF8vIl8xiAp9bAr0o1oxtBEjnVuScu0OHlUQgRusSCO/25R
         QJwOcUBedoCNiy4AZAO7qdYsCtTJY8fIzw5qxminfqyz/HpSgTZcY1M8UmTuNrnAi7FX
         RUm5fcY+KhsnJgDoUqNJNTmd728jtgKcsgHTTcqcHj3WFdgsQeldyLulGDl/dcDRfULh
         WOW3c+6SDWATHbg6dNZJSOp2zq/MbFCCupbf09Lwv/mVdRBb6LQhFVMlQKNkcoTms1co
         aPRPQdAXlJqcj8bjN6wCq9JcvenWieInLRfNlwVMF3UMej4vTIjUqTkluFOp8wwqLpnT
         eLRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UWqjXIcqtIZGoXJHhXghNNIDKwEBlEpB/YPKWMii0qs=;
        fh=SvlLeP7sKlDKatuMVX9oz3IHSFMd3Nrba6rkeNibtn0=;
        b=XeNjhavSgZDjHOzUZCztpqH/jeh5VnELHahZbHHDUyAyILqr6d7OltIYWBRl9p9JP4
         8fApe+queYVlTaE7b+P9V2IS6VA6GYZudnKhNk5IQmnNzB/L+Wg+gDmXmUI7lauKofYs
         5zctz1PHKrBRqEMP+Rq3kQ2O73+SA3bVeAsc+cN5qtYx3peag+w1A13K6Q7LyW+SkPVs
         mzk88P8Lmmen+W7mVmL7dv/+JTddzXEsMfcpleMWwAe8XHA/cE71ytBdgtPjqkKSdrwS
         rdVFBZqGN3hGxyme8Imd0Mp6ybL5YoAHHQ0amqurc//XpmcQ9NyzAXBAYsVL4zxlc4dh
         K//A==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google; t=1787579392; x=1788184192; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=UWqjXIcqtIZGoXJHhXghNNIDKwEBlEpB/YPKWMii0qs=;
        b=NDMoFzvQZiYLhYfgLRj1Ktm3K7LltETOkninXMRKeKJsVGrX/f5yYwoKebcqW5zE+J
         Nuh6crj5oNcOPXEhNSWgsZDXUjnF55flY4e2grH5zeQSUf+xTlynxncJqIWBpEWpcJh3
         2iRMqM1j+sNOmGDXD8voA/XnGZe83Hp5BGNw4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787579392; x=1788184192;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=UWqjXIcqtIZGoXJHhXghNNIDKwEBlEpB/YPKWMii0qs=;
        b=Ptlj7kmfSRzfWPmkKTlTK3GCWrKNU1bm4tpvPGKg0jrqVQt712Ft1VsrVD0Ri2y/R4
         oKVlRkcE0cPWkvGcvb/sdrQ1HtLPUUR0Ob0mP3a1aE6ySBCg8VaH5H+urg4X2FB2KGpa
         Xvh7a43GuGDoVUa4HRpimWE0+k7ND1V1HQFyRcqB2vsdXubERiJfNC8JZHyo3p7b8J0e
         5xt7m0l86m+eUuD9q9n9h7fLtdQdAMDq7LlkCAhtHGk431qcIcppP/76mk4Lirvx/dpk
         mHzZG51viuM4Io6kd2yuoRFQTjpdVXoecygnr1tdlHzvigmcIh/DmlTErw3rGYWqa7/T
         PRYg==
X-Forwarded-Encrypted: i=1; AHgh+RoIx0hREsgFKj+ewDLidDrXNbQjTuyXQA2GCbD2L9aH9eSeZ1PZ9ivbjfwbz5bWs5A1ID61yYmdixM=@vger.kernel.org
X-Gm-Message-State: AFuF++lVGdfAatvzqewEIde7sbluYTuEA/f4ZvJi8Ni3Lq5FsdnZkDod
	lQT5Mh04gzZrmusdSzw8PAOLMsWhXJbKfX7blaZHijzKpgDlr5XTMQu26RxQ/dW/3+EwSLQxrhA
	sc2+DqW/Cu3H2SfVanZzRwye1mF0VeQgkVvC3jDiVhA==
X-Gm-Gg: AR+sD12XoXqraFbImelZLIvdv2MilQLu/Rh4Q3pmRjxow8hbb9lhgU+X0YDpY1BoaO1
	tdtV5jlPXhWiQ0QEhrjuuDVzjYrxt5GlYrbY7vLnckkb4luBwopj3OHvPPxPxcKIEhSUJYlmUMd
	cu8MKKoddsNrRl6qkKK2PGWtvu/Y14dnx2GXWaztPjcYrHu4f7GxPlU2+gGKezcew48HJp6F0u9
	7KPbQbZA8aOCjt3oYRDBgD+8zssnpEgUA3Ro2cvZC8mzPQt2QitWnzs6z2qlkueMoV/SqWRhUbp
	mOrgyOYi/aB172vXt1TnZrmDfAOv5HIqnXTYehjauZ8Ck7w9XOO35QF5TTV91QWl0/AregZx3p/
	fvwU=
X-Received: by 2002:a05:622a:8416:10b0:52e:1109:8f6d with SMTP id
 d75a77b69052e-52e1109944cmr94356391cf.42.1787579392384; Mon, 24 Aug 2026
 06:49:52 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260820193343.3852967-1-willy@infradead.org> <20260820193343.3852967-3-willy@infradead.org>
 <CAJfpegvP3i8ZJc2T=+f4rAhZ4E1QcT5+jC6mQPLxtB-yoK9Brw@mail.gmail.com> <aoxHOSC9kTPbKeNq@casper.infradead.org>
In-Reply-To: <aoxHOSC9kTPbKeNq@casper.infradead.org>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 24 Aug 2026 15:49:37 +0200
X-Gm-Features: AcwNN1WXkLYVG2Rn2OXRtnBdlHWAinn8Fn4WcEVqUKiB1DB-194nq79209afcM4
Message-ID: <CAJfpegv3Ak+qNLb=fTSCSz7-taQ3Ui-Hkmqgn4PaGPe=CR4cbQ@mail.gmail.com>
Subject: Re: [PATCH 2/7] fuse: Use filemap_invalidate_pages()
To: Matthew Wilcox <willy@infradead.org>
Cc: Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, Chris Mason <clm@fb.com>, 
	David Sterba <dsterba@suse.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg <martin@omnibond.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, 
	linux-block@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	fuse-devel@lists.linux.dev, linux-nfs@vger.kernel.org, 
	devel@lists.orangefs.org, Pavel Begunkov <asml.silence@gmail.com>
Content-Type: text/plain; charset="UTF-8"

On Mon, 24 Aug 2026 at 15:29, Matthew Wilcox <willy@infradead.org> wrote:
>
> On Mon, Aug 24, 2026 at 11:05:46AM +0200, Miklos Szeredi wrote:

> > Maybe add a variant that takes that lock?
>
> I don't understand what use that would be.  As soon as that function
> drops the lock, the pages could be reinstated.  If the caller needs the
> pages to not come back, it must need to hold the invalidate_lock across
> the whole operation.

invalidate_inode_pages2_range() together with launder_page guaranteed
that no dirty data remained in the cache after that call.   Yes, the
pages can be reinstated after that but those need faults and the
server can then serialize those against the invalidation.

I don't see that guarantee with the filemap_write_and_wait_range()
(with or without invalidate_lock actually) since the mapping can be
dirtied again without the filesystem's knowledge.

Am I missing something?

Thanks,
Miklos


>
> Before any filesystem people get funny ideas about closing the O_DIRECT
> race, you can't do that because you'll deadlock on doing I/O to the same
> file that you've mmaped.
