Received: from mail-qv1-f44.google.com (mail-qv1-f44.google.com [209.85.219.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B698A3F58D6
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 14:37:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.219.44
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786372647; cv=pass; b=KHAkeBD7uBxFZrlOzPz1b/QJlRHGHaob8+zgu6mpEcBKQHRcZD4OqbHhXMlAjhiqByeAqTwxgvKA14lsg0mBOBifUrHjxlfHDdfGwznsWW+ait46TPNdaHxKcHbToOIfsadWuEzuiISnrCZ/IXOp1bpCDduEXe9bo3P+JXyZHng=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786372647; c=relaxed/simple;
	bh=1TOh47GuX2DYZgrLBuHx9ZqIJlL5qlbKX0nFvU4QG8Q=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=D/XYqpreRUN89ktFZMScO17pLVh7rqAGIUB4h/Ja35iDJGiWrVx0yIHflgi331R2mA0kMxlFWLZKIPH+KGKtJQpWMNWfYmll9dMRDr7Sh+hEAdw9gJvmOPX8uSYspNlmKxMwT+XVIxW3rOFRSMvaJPCz7F3WM1Qn84OHEno4EsM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu; spf=pass smtp.mailfrom=szeredi.hu; dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b=BnjWOSSE; arc=pass smtp.client-ip=209.85.219.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="BnjWOSSE"
Received: by mail-qv1-f44.google.com with SMTP id 6a1803df08f44-8fcc43c48f7so19269666d6.2
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 07:37:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786372644; cv=none;
        d=google.com; s=arc-20260327;
        b=GUinZr5VmL+jysfWTPRWzuYE73IbZkT+HrLChZMgYDdSbyZbJe5Vkg/KCkWGb5AGcY
         Upa18VjrmuumRCaP76n1u8jDQumoADKiguywjYNvO0iyLJ+6a/E/X0HiBFP1oxXdm8NP
         YtLfcqFZPauiEmIQdu2uQ84Gmwi3RCP1E0BoJ02ACREr5AX4uHroo8eNW92I2r7WCtGZ
         FA32TsyAyzgvRD8OpD8vmsICD8I3IQHlheMfrdnB1N2nCH7/9ou+OcoPOE3zvHzIODVO
         NLp+wZAOU6FAX8gQY5IwrHuWS9cIviTrZdV+okuTLTJBghNu9YQJ0CySTLYoGImNjOAH
         DKVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=N9K6RvXQXpCBgnaYxLabarFuImKKDVr9pRNexvL1dnw=;
        fh=ndHALlXS1c9WJxo2L5ivmRTm/vkDpvxbY8aOvK6L2FY=;
        b=MDSOpjs8XfDQF0To7P15ww5541kF/xJajP8WzTc3wMwQc/y1OQFeJzctbUl/J8FM23
         e3GsRbkMb5e+g4pc7St3q650FspOwha7ph5OX1/vhIRbrBACizmNy3gEHUhy8SBRCK9m
         Mi7nzLQcXGaC4Bco6QHRTZufPYtz34UrI4ofJksIGQolNC5GATHBE/fNGqv2NjX3xlo7
         rrCMp4SykwLxt8iZcqF18iPlUVAvZrLP6x3mTY4m1x8k4GIHbpJirB86OgehgL80yvnI
         Nk9n23+WYzRq1BwbEAxSSgioOMhwRCg2dhbonHVKjp/abtn8d7y2jFZZAXGzRV+EhjIR
         F1eA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google; t=1786372644; x=1786977444; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=N9K6RvXQXpCBgnaYxLabarFuImKKDVr9pRNexvL1dnw=;
        b=BnjWOSSEvEzWJR5J14cWubjkTZghiLwSDr8kJW4rvp0BwKy+nI2ukNW8e93CAslQWz
         oCQhP/5/uCvPqx210NpA5dAr7YKD1Po/1H7JGoWx0owTdLfkUjN6DLKhHhLpSAH2I+iI
         vgQcsTPjEjbabHAo6lj8yF/WExkf+DhpOI64s=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786372644; x=1786977444;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=N9K6RvXQXpCBgnaYxLabarFuImKKDVr9pRNexvL1dnw=;
        b=QDV0prjdt/+49SxvalewcVr/WtMbubDtGvzrLR3StiV37O8K4fDUHuBqAKmxAOcF2r
         Q/KR4/lODRZZ4HNv9WmOGnHJkv4Q6TJg90DX5j/3gktJ31GRzZMjRuWQ5YZT139kkYqy
         /tZVUm9zpP68WV7Cq74G+nG3aYe7g8EaVZn6j5z9YXLkpOoaSuZ53xG9O5DgdiE9k/Ya
         dQWjNZ78VnJx1Jq7u2QUCTBp6PoHe1saJ0ndkrWsMtSfBQ4T1R9QB9CL+7v5QNsEug3I
         AjBbtTwstkHYboKeFz85kEu9O731yOBkbrIvhqaPtbGgZLKeFlFnGLJ8jC+J3vXEnau8
         x/7Q==
X-Forwarded-Encrypted: i=1; AHgh+Ro35eo/6p6ZyaRyjSC0x6Eu1EVz/l8UezaCzcoL5MpzWwIb4jXA4dR7lzbKPlzhR4JAXHklcZiF3wU=@vger.kernel.org
X-Gm-Message-State: AOJu0Yw09jOS+QUEHwM1g8t9cv8eS/NG+1HPTc5ad4aSffLQ0bcUjZ6P
	aVTyOdM3LcI/s8egX8RRMoqNCdOvf0FplM9XiKgyQX379NaSDKs+LwP1PgyPD9ubmfx0JZg8e7Y
	CdTLR7vsJKe8umlyhWYGBEzoQbkd+MYk8u9Gk15C1Tw==
X-Gm-Gg: AR+sD10YgNZN3rJbhpJJblH3zpeC9QxiHzXMgq6QnaICA6kXVCYBHRkyDBGne9jTaZ1
	c/nNgMtBmDrNzIkDNn+qGElEdJpGm8pYgZaV3vtGEPFB8SYdoAjCzoV+K+wkrtyv2C0+Ea1Ax9+
	N+ybNAYuKTYP95Q3blWWHfpmqzpQga04YBPzIsYAELcsLS8Zq9KNJmU3oJVX+KAKJg95M4bpYEN
	cP0TKzN/zgwOMKtp/vUGl3EtC8KKPSiE+V8tQzikKaTx2wHVByCPDMPxJwMMtGKQdhHnQwxrK2u
	dncAx32x3GztlSMmFESFW2tF2rPIxpRaAoq0ixkcNOZXF/oNl3ITwzoBD7tc4gpp/FfmoaET+zD
	X3ObDZ0hZjA==
X-Received: by 2002:a05:6214:20ef:b0:8ee:f531:4de4 with SMTP id
 6a1803df08f44-90a5dfa37c0mr27777156d6.13.1786372644393; Mon, 10 Aug 2026
 07:37:24 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260803012648.2195405-1-neilb@ownmail.net> <20260803012648.2195405-5-neilb@ownmail.net>
In-Reply-To: <20260803012648.2195405-5-neilb@ownmail.net>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 10 Aug 2026 16:37:13 +0200
X-Gm-Features: AUfX_mwDV5L6hLfp08WK2RA4_U7t0g-kBuPpgpA2dBgLwUCWyqeJ369EboEHc-4
Message-ID: <CAJfpegv2TTEGgfFBvAB1j2ixyEMXruG0AhL=R9iMC-LMJToiAg@mail.gmail.com>
Subject: Re: [PATCH v1 04/12] fsnotify: reduce i_lock hold time in fsnotify_set_children_dentry_flags()
To: NeilBrown <neil@brown.name>
Cc: Ian Kent <raven@themaw.net>, Chuck Lever <cel@kernel.org>, Jake Edge <jake@lwn.net>, 
	Ilya Dryomov <idryomov@gmail.com>, Alex Markuze <amarkuze@redhat.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, Jan Harkes <jaharkes@cs.cmu.edu>, coda@cs.cmu.edu, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Amir Goldstein <amir73il@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Miklos Szeredi <mszeredi@redhat.com>, autofs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	ceph-devel@vger.kernel.org, codalist@coda.cs.cmu.edu, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Mon, 3 Aug 2026 at 03:39, NeilBrown <neilb@ownmail.net> wrote:

> +       /* Find the dentry for inode - there can only be one */
> +       for_each_alias(alias, inode)
> +               break;
> +       dget(alias);

This is __d_find_dir_alias().

Could add a get_dir_alias() primitive that does the i_lock locking as well?

Thanks,
Miklos
