Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 378F62EEE7E
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 23:44:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787096664; cv=none; b=T0A6aYakW951qfJe0F8Yo0Se57Jz8EBap3yeI83iUpS6R85vwYM5vpZHJj9uhgJiPutnOgDe0cwqR6TIkXjqJEpG6CIHWtTFTI2GMh0mtP5kPLHfENAcYRh7GK8T7WwpUCMH34UhHmyKQ8MCh0WGA6mEGRqXT0dBnAyQmOncR9Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787096664; c=relaxed/simple;
	bh=uYahM4qX0slR/T8O7Hkh398ColyuT0UrhksCvPZbpfY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=u1tjdUqLnSKwJyqDjoyqM2em0IqO3TmM6ECEnUGiAyl7044XsR8TnD1IPwVTl34Q/f1q03EQ1WwVfKB0UoBPwQN2wnZxrN5G2ADyuRuITvvOf2GYhLO7vuGemtAyWg1spWClYI2c58obPntaShRlDhqusOhGwZWZgO3Ifo/o/+E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=GBlsQ13v; arc=none smtp.client-ip=209.85.128.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="GBlsQ13v"
Received: by mail-wm1-f45.google.com with SMTP id 5b1f17b1804b1-496bb7cdf51so4731755e9.2
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 16:44:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1787096661; x=1787701461; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=o92sFe44ydKdGQASEJ137OI8u4J3XXbb5WVttyLKR34=;
        b=GBlsQ13v5Ldp+lFZUEY/C8MlOnLC3cT09DEOIh5qlOGyMHRBvmUFo/tQiVFZm5ES1N
         6a0gSjPcNZDsGE5lTSeOl/OWPbI+yznkYFHL7qRKjjZ+khjB7OMsccjM8fSeZwEZU9Mt
         ct0A0ob4QvYbhLzYEq6lKFOF0NSCeu11O9DvUIrQj8gNOIWAP3Qrh4w3pvQtqVZ0s7Zb
         wNcLphwTodVosp9ey2gh8f2iCO1jktJn9xuB+0FKAgsSpn75G7NGdE0Q9k0b1NCzgbG3
         +uP9nMpM5vRqxqFJJIaQwLCAe+QLgCCE4CnApPDiBPdmSr8tzzsR+V5MgrLTeuv4na/O
         7/RQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787096661; x=1787701461;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=o92sFe44ydKdGQASEJ137OI8u4J3XXbb5WVttyLKR34=;
        b=rSdSyHXiZ7Par8S51SRDQW5Cxxx7Tpr1xzipsz2n6cLgQ995Ip2HPQ/xD+ropWnrnr
         rxrBe2DjwtuvEOYq2jzfBs2MBwozVrnVaO8g9K7GDNmDsGQTalzdCouGbVjZbhQlBFu/
         35VOFaDwzxDlTqk8Ks0i3N/lpRo5wNWJ4Iz7DvMCuM1lGLZSQuwO+6googKlCpqQNPag
         8/7mqJ4FDgHKPmJnQwK5pQnNEE5ti6nOyerkh+ETAMagE1It9qJYCi5EkBihUzS/Dsbv
         GF1nxMa9dxZKJ1vU05SOp41GPAzAq0aX/N1MflO8/tKxbi4LYfzetiPAz5w2lySlb01W
         q5JA==
X-Forwarded-Encrypted: i=1; AHgh+RrQE8vtDkn7QJE5+4HCCW4OOw57mEVYrP4zFa4VszXl8ahEsCvq54xMkg05MephfDb9Sd9M1x5TeyE=@vger.kernel.org
X-Gm-Message-State: AOJu0Yxz11CtGNwiSgZ+CDQ9VZ2d4u6Yy2y/IBhTzEA9SIjYTzhoNrJU
	h4BjnkdrS1/mhKrDspebBKdZkvP6RM87V/95ub3RVehkZeX8k4G7P84xy+sgtEn+Pg==
X-Gm-Gg: AR+sD13u70ClHYtE3CsX/xpskRN4fpk4tH8MIycSEFm083Oc7H9797RqmBk1JB7tjUH
	gwD5M3MHO+jRHP6dHZ8vKaHTUW3nlg1TZpfL1HJ8WQLcKb6J5EdPtbr+lFCmeSEezRDeUslFTjl
	hvS981m/hOdho9an6eKdd1/z9E/HfklW3AO1bIRXpCXZfq7/UHAIXJtnq3sxa3Y1+WdlgZna2uW
	sIu7QaYJnOCewyBySgeo4T74lIO49MxsPhDG9Yxum5TbHP+WT3p/AUqihjAA58mB4eVSkLxQYmJ
	tabL8LbyySgRTEfbZY74dcqfrCvxtHQDX1kVazKgpHdouLnVreu5Gvb8EEPs58HwRqV+y/cHP3U
	bgtESExf50A/QY2EVdTXUMOaGQW121p2L/EZEDmxX9HydKbrrIkdxvwFZnDW+CJxmSRqbWZjn5W
	igFGazXu4FxDQZ8sz2ialUWACS0utLJDCIJODn6Wbj
X-Received: by 2002:a05:600c:4ec9:b0:495:52a5:8829 with SMTP id 5b1f17b1804b1-499aa1e26d5mr9797965e9.11.1787096661464;
        Tue, 18 Aug 2026 16:44:21 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700::1])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-499a9aa7e8dsm7825595e9.0.2026.08.18.16.44.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 18 Aug 2026 16:44:19 -0700 (PDT)
Date: Wed, 19 Aug 2026 04:44:14 +0500
From: Ameer Hamza <ameer.hamza@truenas.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: cel@kernel.org, jlayton@kernel.org, neil@brown.name, 
	okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com, trondmy@kernel.org, 
	anna@kernel.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	alexander.motin@truenas.com, caleb.stjohn@truenas.com
Subject: Re: [PATCH 1/2] NFSD: Use nfsd_iter_read() when ->splice_read is not
 zero-copy
Message-ID: <aoTuAnr4bBLg-BGf@hamza-PC>
References: <20260817210811.3984663-1-ameer.hamza@truenas.com>
 <20260817210811.3984663-2-ameer.hamza@truenas.com>
 <aoRvOZTxA1kxBO9x@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aoRvOZTxA1kxBO9x@infradead.org>

On Tue, Aug 18, 2026 at 07:42:01AM -0700, Christoph Hellwig wrote:
> On Tue, Aug 18, 2026 at 02:08:10AM +0500, Ameer Hamza wrote:
> > For some files splicing a READ cannot avoid a copy: gfs2, kernfs
> > and the cifs direct-I/O modes use copy_splice_read() as their
> > ->splice_read, and the VFS substitutes it for DAX files.
> > copy_splice_read() allocates a fresh page for every page of
> > payload and reads into it; nfsd_splice_actor() then installs
> > those pages in rq_respages, displacing Reply pages the thread
> > already owns. Both sets of pages are then freed.
> > 
> > Route these READs through nfsd_iter_read() instead. It performs
> 
> No.  None of the above are sensible use cases for NFSD exports.
> There is no good reason to add a barely maintained special code path
> thae pokes into internals for this.
>

Yeah, agreed on the poking into internals part. I will rework it
in v2 based on Neil's FMODE suggestion unless you have something
else in mind.
