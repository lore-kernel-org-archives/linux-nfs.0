Received: from mail-qk1-f180.google.com (mail-qk1-f180.google.com [209.85.222.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C6AC3EFFD7
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 09:05:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.222.180
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787562360; cv=pass; b=GC2Snp83qISbQHe8Zz+hTejlLbC+hJtSQ6YclS4Z3rV/IPvNNh1GOBsKG5Ch+8xA/HZ/sm81+tqe+tYtUusSOcCvnavC7L5aSOTpiUBj7Bmxw49yEo77ZZGFVb18YQaY3zAjlawAdeJvCnon2OnIMDRT0e/9coGCDBWvWvF2alA=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787562360; c=relaxed/simple;
	bh=k1VcahloVqTMd2bS2EdontwtzK2WJK0zze95i6TSOFk=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=JDi8qLm8WzK/Iziw9JQMZxXQs43JuxV9lvt9vxen3hYnyD5w/MxT5juW30Ur2hGvsSYbRcOwooRDq/DHdY9Qmy56C4RhBUlc8XZzSBYZZ00X/dHXu4B6VrAVWvZsqvY2GK1GGRIsnrq0jxsXfQNxhEspWizHo05DtJOxiND7xPE=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu; spf=pass smtp.mailfrom=szeredi.hu; dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b=Md3V02RB; arc=pass smtp.client-ip=209.85.222.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="Md3V02RB"
Received: by mail-qk1-f180.google.com with SMTP id af79cd13be357-93695893ac1so185708885a.0
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 02:05:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787562358; cv=none;
        d=google.com; s=arc-20260327;
        b=MEcaMSzw2M8sliYFvpeiQtUD97xJyq0dtHY4DHOjz0VBXB4vytMxEsEs0VgMqigbMM
         d+n2m6PBLZ9j2kqess/9N7DakJ+I5ynuer77EQ+oXswxOj9AUFUWXSQMk8DmhSHM7Y8Z
         bhRb6WyJ+y3gVrLcYua+N8e0+HxaWweBO/5jCwxo1MZ6HEZBvc+tLkBs8hIIB8AMwKbm
         jp7DQ0ojw3Ud+4vbmbrOzot0rxfU1lnwj9yGEdSePGIJI0eS9T5WMF2pgH0orZH3BHws
         QtyHbW8aX4QBdMG10SrAGLRR+arDd3Mh4NsaGEbjmtygiVFphmsqaxMDuc8Xh7qDXqXA
         s4WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xjSchm007/sw+2JfMjG96f8T6RE12rgCCudebYixRu4=;
        fh=nsMtDF4D6D+0UwzF4Oznhqr3KbMjNQza2SM8pHGyMok=;
        b=iUuayAX0iyG9g/T/qOxqc3H1iEWgogmVv8F051cgWhbKY3If6Y1MEcUFfc8nYfcOqK
         xoNF+JZsFZ7/fOY03nH4utvZzo+wa/tQD7C/w3SZr6tdEl8F21/onI1uWlFiTm18eTO/
         tU63Xjk7hfogpcVfM09tYnuE1HU0rkmYpvhwitfPLde3FbvLAJtLu7gH+ZsCnbqYsP6k
         6u5NglDCIUux1iVxnNgpphnJPlp9W1oFAZ+BMKF0yh23tSEMNR5iiuNgA3HEslHjseWm
         ajJ67VNcLU6tyOyXu0W6uyozfaYvHPnH2KNpNJDWRhcAzJKRsooExKK1xoW+mtD2kxy2
         GvLw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google; t=1787562358; x=1788167158; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=xjSchm007/sw+2JfMjG96f8T6RE12rgCCudebYixRu4=;
        b=Md3V02RBMrXT7++lZjkapZopD8qkdAFSHpNsSv6QmBIPKOdzQWCNN6AR4kmpFvkadv
         0WjoUBO4KWY/LQLlyBAjyM8JJ34zje3REjajNVZ3Gow34PJ4FI1D/qOFI4wkzef/51KP
         WjSj07LC1JS0zXh2vxVUSAXHu2k8KyBR3WWNA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787562358; x=1788167158;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=xjSchm007/sw+2JfMjG96f8T6RE12rgCCudebYixRu4=;
        b=ZhwiDvcq8iHXnGsq0GSJdP04yB2RaNcmict0QpHGA6fdhrSL5IkyWp8fUh2e7rS9hE
         AYGn8aH0KX1mlVD/7sCnU+7mCHd0OoUnrElF1IH6AoOwxJdvalRMmUYIpaBMsXYH3+1C
         7hliPmWOUHbB+3xhM9UNwqRAlK4JnGv+kffxpugOJDw9JWvrGKgJiarrJPe3PM4auQzd
         Plxks9Ll8P9zNduba/rWfzLqhrAHrOCEtTHX2v21GWRI5bap/T0YkurSQ+jdmMFhsW+2
         jb7s4C4mJh46fwVGKM7Po+YHOlnn2TDUCd/AclXLVBREWRAtxDCUrsgLEiYp4dkYipup
         FHkg==
X-Forwarded-Encrypted: i=1; AHgh+RqnBBrI9wkJHRF1IUMitKz8JEqKbhgs8eMuzB3Yp6QMrlaE3nArYd4xyqHKKnwTJKyo+CkYa8JhE3o=@vger.kernel.org
X-Gm-Message-State: AFuF++lbtXLwWi2Q7cfg9Oq7DpCkuMVtdlAlPr9YSmutwRrjxqLfbjdY
	mpXFmAW8gj3VWPygtRMEVZLvX/w4sRzCsrUAW/jtV7zcWJEWXZG9aKDhISAJ3zS90RdrMQX/6q4
	7aNOjld86XQ8bYF+kYGSwNx6ZNGXmn5o2LkPGHMI/0Q==
X-Gm-Gg: AR+sD105eeAmD/v7BWXsL1z7B+VHrn7YBhmglc13qE9ItYN7L2x2apzcNaCnZmkU3Hl
	mERyb0p6bpY5JmS3e+Hxe3AJFzA/yJLt/gaKfhRUfntqdzJZ+3SI54PO8124dqtLh5BGZpzZKmk
	CCB+vclOBWUgnUHybrjLH3NLdffMCDu46zQIxl2yj/QeMJK1GIam5xeTYAPNcHs2Q4bQJMuuKLJ
	/Fik/EkndNJ4ahWtZ53HcM+8riIj6MLHOV7GNZMiMSccsAES3bzLKkjaVugTSK6+YhNDdNLf+6D
	dK4leNTEjpQoZXsGq4mKtq7M4tqLWpiZExadUgxLDTN/nBKSSWIHXzzZM3xOj8ymFH+LYPpz7Ch
	RN38=
X-Received: by 2002:a05:620a:a2c6:10b0:92e:bbd0:260c with SMTP id
 af79cd13be357-9373957655amr1668397485a.36.1787562358062; Mon, 24 Aug 2026
 02:05:58 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260820193343.3852967-1-willy@infradead.org> <20260820193343.3852967-3-willy@infradead.org>
In-Reply-To: <20260820193343.3852967-3-willy@infradead.org>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 24 Aug 2026 11:05:46 +0200
X-Gm-Features: AcwNN1VnwXUZIDZ1PfaZZEyLrhKwB3yAlvrDYfoxcRnFp4RHIk-2JE_xMlB98T0
Message-ID: <CAJfpegvP3i8ZJc2T=+f4rAhZ4E1QcT5+jC6mQPLxtB-yoK9Brw@mail.gmail.com>
Subject: Re: [PATCH 2/7] fuse: Use filemap_invalidate_pages()
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, Chris Mason <clm@fb.com>, 
	David Sterba <dsterba@suse.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg <martin@omnibond.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, 
	linux-block@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	fuse-devel@lists.linux.dev, linux-nfs@vger.kernel.org, 
	devel@lists.orangefs.org, Pavel Begunkov <asml.silence@gmail.com>
Content-Type: text/plain; charset="UTF-8"

On Thu, 20 Aug 2026 at 21:34, Matthew Wilcox (Oracle)
<willy@infradead.org> wrote:
>
> FUSE relies on invalidate_inode_pages2() / invalidate_inode_pages2_range()
> doing writeback by calling fuse_launder_folio().  While this works, it
> is inefficient as each page is written back and waited for individually.
> Far better to call filemap_invalidate_pages() which will do a bulk write
> first, then remove the page cache.

filemap_invalidate_page() suggests to use invalidate_lock to prevent
races with pages coming back.  I'm not sure that without it the
behavior is identical.

Maybe add a variant that takes that lock?

Thanks,
Miklos
