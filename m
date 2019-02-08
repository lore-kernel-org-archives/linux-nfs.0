Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A763C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 15:07:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EFBEB20863
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 15:07:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WqZT9RhM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726887AbfBHPH6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 10:07:58 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:37796 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726813AbfBHPH5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2019 10:07:57 -0500
Received: by mail-it1-f195.google.com with SMTP id b5so9558398iti.2
        for <linux-nfs@vger.kernel.org>; Fri, 08 Feb 2019 07:07:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:message-id:subject:to:cc:in-reply-to:references:organization
         :mime-version:date:user-agent:content-transfer-encoding;
        bh=YtzwsFpBnIHorRfyleS9mjSAIhrZknO+kZbcDSiwqkA=;
        b=WqZT9RhME1iF5taHSurD52RJMZDm0sJHeIMjKpdzFnuwqMuWAoLLAGCX256BGlJc9W
         poRD3kxOAABx1uUYS/kYHT8PzFGqEQNGwKViNed5M05QSq4ut5aOQ1/xfMzQN1RyHnPi
         Bkzg5z9O/iQ0NH5GEeNBR4yZtDIHxoqYo3k7S0Vlh+Rz5WrpzZVOVedn4vhddJn1MpQZ
         ukZNXeRxL5l5GHI0iz+gwJJoAP7mngIsAeK5tGo6lMJiIWABsdv+kJWj9AI9lKL1dmFI
         +HLvzA0x27ukq0leTVjacY4OfAOmQpwTdHHWwcd+0LG4fssjerOWDrUIiywaS+jPqQdE
         jq+w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:message-id:subject:to:cc:in-reply-to
         :references:organization:mime-version:date:user-agent
         :content-transfer-encoding;
        bh=YtzwsFpBnIHorRfyleS9mjSAIhrZknO+kZbcDSiwqkA=;
        b=Vfp0+PytrRIgNpx43usZKnCfv4OgyqkW4VwLf1sOKSkNLzB1u2taGI1odwFAvZ+uWs
         EoNofYZDr/KcNZTjARU11rrVPimnitfdUv8idko4SBznjgoxpzPgXxSqz0zpKn2VDEyW
         AG+oD9JNQCpDYRhiWxWvM1qdjuE2zIggaGWCzWVeL9Lq+HtKxvSFhZJ34yO9H0hAkePO
         NOeYSctuTdsqoGJYYauPjbQ1lQAK0v7b6iytsBBZc5W8lCf1vcTH/NGUxN1kRBhoCQAl
         P3HC/Uh1ZGAceZOZNnE+B9JRCjWAe12k9og5Pe5kVypPoNWea1d/ZLSJNand9EyJ1877
         eOvQ==
X-Gm-Message-State: AHQUAub5Y9bz6TOyKRTAbWmiCz/IGEO67ntCj7CKU33zQQ1pyaSePNbs
        6x281Hap0Q5tlGYVl8g3oA==
X-Google-Smtp-Source: AHgI3IYAnxdpH2SpB/2y/3ji3DZ58Yo0fqZSvKnkIkeuLUo2CGHLh1vQwrbo2wNpg9xH/W1vo5lQLg==
X-Received: by 2002:a5e:dc0d:: with SMTP id b13mr6545441iok.269.1549638476343;
        Fri, 08 Feb 2019 07:07:56 -0800 (PST)
Received: from leira (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id n129sm1393135itb.20.2019.02.08.07.07.55
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 08 Feb 2019 07:07:55 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
Message-ID: <17e929a2eea3d2c33dcd3d2c9b8d8a932568be47.camel@hammerspace.com>
Subject: Re: [PATCH] pNFS: Avoid read-modify-write for page-aligned full
 page write
To:     =?UTF-8?Q?=E4=BC=8A=E8=97=A4=E5=92=8C=E5=A4=AB?= 
        <ito_kazuo_g3@lab.ntt.co.jp>,
        Benjamin Coddington <bcodding@redhat.com>
Cc:     Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org,
        Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>,
        watanabe.hiroyuki@lab.ntt.co.jp
In-Reply-To: <4332a67f-0d50-cc30-4e2b-8d08a112a76f@lab.ntt.co.jp>
References: <37261782-eebb-b9c5-a480-7ced59b3703f@lab.ntt.co.jp>
         <5905EB17-75B9-494A-B608-F135D6330F49@redhat.com>
         <4332a67f-0d50-cc30-4e2b-8d08a112a76f@lab.ntt.co.jp>
Organization: Hammerspace Inc
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Date:   Fri, 08 Feb 2019 09:58:56 -0500
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2019-02-08 at 16:54 +0900, 伊藤和夫 wrote:
> On 2019/02/07 22:37, Benjamin Coddington wrote:
> > On 7 Feb 2019, at 3:12, Kazuo Ito wrote:
> > [snipped]
> > > @@ -299,8 +305,10 @@ static int nfs_want_read_modify_write(struct
> > > file 
> > > *file, struct page *page,
> > >      unsigned int end = offset + len;
> > > 
> > >      if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
> > > -        if (!PageUptodate(page))
> > > -            return 1;
> > > +        if (!PageUptodate(page)) {
> > > +            if (pglen && (end < pglen || offset))
> > > +                return 1;
> > > +        }
> > >          return 0;
> > >      }
> > 
> > This looks right.  I think that a static inline bool
> > nfs_write_covers_page,
> > or full_page_write or similar might make sense here, as we do the
> > same test
> > just below, and would make the code easier to quickly understand.
> > 
> > Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
>  >
>  > Ben
> 
> As per Ben's comment, I made the check for full page write a static
> inline function and both the block-oriented and the non-block-
> oriented paths call it.
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 29553fdba8af..458c77ccf274 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -276,6 +276,12 @@ EXPORT_SYMBOL_GPL(nfs_file_fsync);
>    * then a modify/write/read cycle when writing to a page in the
>    * page cache.
>    *
> + * Some pNFS layout drivers can only read/write at a certain block
> + * granularity like all block devices and therefore we must perform
> + * read/modify/write whenever a page hasn't read yet and the data
> + * to be written there is not aligned to a block boundary and/or
> + * smaller than the block size.
> + *
>    * The modify/write/read cycle may occur if a page is read before
>    * being completely filled by the writer.  In this situation, the
>    * page must be completely written to stable storage on the server
> @@ -291,15 +297,23 @@ EXPORT_SYMBOL_GPL(nfs_file_fsync);
>    * and that the new data won't completely replace the old data in
>    * that range of the file.
>    */
> -static int nfs_want_read_modify_write(struct file *file, struct page
> *page,
> -			loff_t pos, unsigned len)
> +static bool nfs_full_page_write(struct page *page, loff_t pos,
> unsigned 
> len)
>   {
>   	unsigned int pglen = nfs_page_length(page);
>   	unsigned int offset = pos & (PAGE_SIZE - 1);
>   	unsigned int end = offset + len;
> 
> +	if (pglen && ((end < pglen) || offset))
> +	    return 0;
> +	return 1;
> +}
> +
> +static int nfs_want_read_modify_write(struct file *file, struct page
> *page,
> +			loff_t pos, unsigned len)
> +{
>   	if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
> -		if (!PageUptodate(page))
> +		if (!PageUptodate(page) &&
> +		    !nfs_full_page_write(page, pos, len))
>   			return 1;
>   		return 0;
>   	}
> @@ -307,8 +321,7 @@ static int nfs_want_read_modify_write(struct
> file 
> *file, struct page *page,
>   	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
>   	    !PageUptodate(page) &&		/* Uptodate? */
>   	    !PagePrivate(page) &&		/* i/o request already? */
> -	    pglen &&				/* valid bytes of
> file? */
> -	    (end < pglen || offset))		/* replace all valid
> bytes? */
> +	    !nfs_full_page_write(page, pos, len))
>   		return 1;
>   	return 0;
>   }

How about adding a separate

if (PageUptodate(page) || nfs_full_page_write())
    return 0;

before the check for pNFS?

That means we won't have to duplicate those for the pNFS block and
ordinary case, and it improves code clarity.

BTW: Why doesn't the pNFS case check for PagePrivate(page)? That looks
like a bug which would cause the existing write to get corrupted.
If so, we should move that check too into the common code.

-- 
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trond.myklebust@hammerspace.com



