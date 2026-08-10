Received: from mail-qt1-f175.google.com (mail-qt1-f175.google.com [209.85.160.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EBD5240B109
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 14:28:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.175
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786372100; cv=pass; b=fJdDIEmtkBWJRtU7dc8+Tg/wXCFdmhEONMYEnGb6DuH6FMhHdunDfeOWMv+MKi3bM1iYGhQh5gZabtkaCr7WixuujvqhZulnwhyxiYbrrWTYz9gCzHY8ydvwp9Mxbqg9I6H7XaIWGzEMNbE0b5b6wkfQICil2CvllJziviQZ5VY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786372100; c=relaxed/simple;
	bh=pnDzUOaejzbZKnGiFAwhq774ZLfxQebZ6F3KHCN/tGc=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=jrfN1HR6JmHppIFerfxqw8x/IB1dY15SJW+83YUy3JEC1rBAvhsO7qPZ4Glv67F+lfHedYlQDV0xdyWyc60nbUnNWxvT1D+Sy2DJLz9sf0/1Mkd9c1cm+RYx0Q2VLc/RICXJeaU/hw/HUzK8MyHXBF2mX4Lvp8EuaV67mJEaTfQ=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu; spf=pass smtp.mailfrom=szeredi.hu; dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b=eYi5XFBL; arc=pass smtp.client-ip=209.85.160.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="eYi5XFBL"
Received: by mail-qt1-f175.google.com with SMTP id d75a77b69052e-51c16ac21acso11602501cf.0
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 07:28:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786372094; cv=none;
        d=google.com; s=arc-20260327;
        b=oTwKEVabhSZeaHRouIxDjcRXRoYZldDpQTpp+MOOEiLKo5WiBgIVXVhAFqf+DVqFfY
         TqNEnAz++9y/0pLe9Vd7jtyh7saFa+Kkze0DLsxrqguPhN6+UC+sR/K5PXq/yw4I4iPY
         SWmuP+b/jpSFXTnNF6oXTVetBPq2Ofs1Sd8DeYbAHE/L1PNfOStFRsGIDPwCAsplBh7x
         Oo+eIwr6AjpeHahy9T1q98HQzGsdj6PAlWjTAs2pU+DQfdttaFcTWW71skP729tWdrHI
         bGuzG+Vo5s8HHhomfw0s9LjsyE7vIwcnka1iG8fihzJuoa8/QmO2cWN8LNajHSDNRrMl
         apTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HfZtRdoG1wYrWSHQiZIrbu1I5YDILrACp6t1fSS5v/s=;
        fh=k2AylrtePMd01reJ9CL0f3ey0EpLPOiJG8rvlLsOXgQ=;
        b=R68IYBOdPV/qYovDf34OSl/4PuRakcTNMJjRPhW6wTDRkUjsyUAW8cWFWdNzGU4Cy6
         nDYNSfSnMG818IqHzBaze6nnvxvcm1DpVjUyNhifMQyzC3E59jUz9g1/7kXTUPKyLBKX
         LleiCgoMnOgUdvoliMZFIJ8YeD62hEZyozLK23/XmrVMHk46CBuc2xJklHvHTwEFWTGq
         f1ITnMbJ1h2/Y6i7pCwQXn0jPGeo80EMF8vOj1J6gMcaFOI0YtKtm9s7r/F7vEW9dWy6
         uwec4uggKdD24BbRgYE33dtAFyXX8jxWd9UWo9exzXn3HQzHlWoNBcDLd1Fr2teiOAZC
         kwsw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google; t=1786372094; x=1786976894; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=HfZtRdoG1wYrWSHQiZIrbu1I5YDILrACp6t1fSS5v/s=;
        b=eYi5XFBL4lOLQZHq370I9VsIpsf0Hgt0nVSXeSEb+mmlrKHaJI4QsZSEEiTfiAJQOI
         BtwL1guQfj4kSPT3K1/+8ZmOHuVonXv7JrNDZggKxBZHRcaY43DswgZKTCHAkwJm+/CR
         LPGeYPx1WltgV1D0yMRC7WESmzvvQ0ZMDGIic=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786372094; x=1786976894;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=HfZtRdoG1wYrWSHQiZIrbu1I5YDILrACp6t1fSS5v/s=;
        b=pY2EsMCShA8GGWkWhx4ezexyxMCLK8WZmMw1ssigzR1GRovII2fSZyCp1uArC7LP7g
         aH65BwAAGukqLPhgoPq+4Gu2F84vlljhlwvc1tBegPx8Id/gutQk9i9r+yo4egVaMEOK
         eZ5mDj5h2T+LndqRvWrmVrka76lY01WCe0R418fjF7by4BAEQ+dEWKTu9HGLi0I8Zo3l
         d82XGoDAJG9gHjGne6+jAmUREQdeNmCDbGJS5EHR3pMt5sccOfHkRbk/oIU92Yalb9aY
         v994NnMf/6qck4Oe/DHUGP4obX6wEfaM2y4/fEtotcqVj1yTSfD5dXjcF1VoX03su7C/
         pTDw==
X-Forwarded-Encrypted: i=1; AHgh+Rojsr1k4gvS2rREL3c9lZ6dUwZEvC/0UmiXFH7P5fzpMSFiYyqJvCzzpropEH9kdUN3OToIvztCo/A=@vger.kernel.org
X-Gm-Message-State: AOJu0YzrJPJRc/PNdTwqNc6IJwJmD7KOMKRD+RD1CxQyKCEbGKOgmXMq
	20SbuUXD6mouDstSIjIDe5wZ9Y9kdCFoOA1t3Z17vH/mlCBwecPVz6ToVkzkvxVF8PSlAshegoM
	wobn+xPhLgQWU4tvK8Zl0RJo6ZKg3fF2XhxkKvbwhcQ==
X-Gm-Gg: AR+sD12DHbuCHKrd26WqmyOQzFGaEPVBMxOmO450W+uyxKqUbQS8m/bP1EZwVmUn8nk
	Na13v1HnXQT2xQhjqIoYflruoBqHIwErXQey/xP11qyPa+cWMx918epwkX2em1ecDXFEDEZHHG7
	abp2izwFrTAqW1ZRoBhWcKwaaRZUFPc21VB6vLNiKH4CmlJpmjSOcD1hoano0xf6GDOAWcRmMlS
	HzoF6ovSNGOhuhN6tDzpyEmS/qvsZKeFHF7sgdANbnYJzDwOEoAIoZowP6TsWB20d6q87ZCL++E
	SHxWQ+QTRRsGLGkuSm6iKDBSn9Z/8PPsUQVs7fk+nBY4DiVoxO+L0VtQIzThR/PgV93GE9U+bPM
	=
X-Received: by 2002:a05:622a:64e:b0:528:583:a6c6 with SMTP id
 d75a77b69052e-52d18e1b942mr222143421cf.6.1786372093929; Mon, 10 Aug 2026
 07:28:13 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260803012648.2195405-1-neilb@ownmail.net> <20260803012648.2195405-4-neilb@ownmail.net>
In-Reply-To: <20260803012648.2195405-4-neilb@ownmail.net>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 10 Aug 2026 16:28:01 +0200
X-Gm-Features: AUfX_myUlEzBYTf-8rEmM-ECZTiH7eaZjHfGryDDDQcizrarEk4s5RrECFPlIkk
Message-ID: <CAJfpegs-k3skRGiwZvQLzD7OrAK4KL8zwmpmJKyjRHSQ-rqX+Q@mail.gmail.com>
Subject: Re: [PATCH v1 03/12] fsnotify: don't hold a spin_lock across
 fsnotify_recalc_mask() calls.
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

> @@ -116,11 +117,15 @@ static int dnotify_handle_event(struct fsnotify_mark *inode_mark, u32 mask,
>                 else {
>                         *prev = dn->dn_next;
>                         kmem_cache_free(dnotify_struct_cache, dn);
> -                       dnotify_recalc_inode_mask(inode_mark);
> +                       need_recalc = true;
>                 }
>         }
>
> +       if (need_recalc)
> +               need_recalc = dnotify_recalc_inode_mask(inode_mark);
>         spin_unlock(&inode_mark->lock);
> +       if (need_recalc)
> +               fsnotify_recalc_mask(inode_mark->connector);

Is the fsnotify_group_lock() held in this case?   I don't see it.

Thanks,
Miklos
