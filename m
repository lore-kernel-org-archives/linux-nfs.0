Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CA9DC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 14:06:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1B02A2133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 14:06:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=janestreet.com header.i=@janestreet.com header.b="Q1QhirB4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732274AbeLQOG2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 09:06:28 -0500
Received: from mxout3.mail.janestreet.com ([38.105.200.229]:33294 "EHLO
        mxout3.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1732411AbeLQOG1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 09:06:27 -0500
X-Greylist: delayed 349 seconds by postgrey-1.27 at vger.kernel.org; Mon, 17 Dec 2018 09:06:26 EST
X-JS-Received: from [30.40.81.8] (helo=tot-qpr-mailcore1)
        by mxout3.mail.janestreet.com with esmtps (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
        (Exim 4.90_1)
        (envelope-from <cperl@janestreet.com>)
        id 1gYtRj-0002BP-Pu
        for linux-nfs@vger.kernel.org; Mon, 17 Dec 2018 09:00:35 -0500
X-JS-Flow: external
X-JS-Received: by tot-qpr-mailcore1 with ocaml/mailcore/main_production (71f307ccacc9)
        (envelope-from <cperl@janestreet.com>)
        id BcF6wD--PgTIA-XN; 2018-12-17 09:00:35.787664-05:00
X-JS-Scanner-attachment: No attachments
X-JS-Scanner-esets: Not scanned (internal mail)
Received: from mail-it1-f199.google.com ([209.85.166.199])
        by mxgoog1.mail.janestreet.com with esmtps (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128)
        (Exim 4.90_1)
        id 1gYtRj-0008P9-MB
        for linux-nfs@vger.kernel.org; Mon, 17 Dec 2018 09:00:35 -0500
Received: by mail-it1-f199.google.com with SMTP id 123so14783222itv.6
         for <linux-nfs@vger.kernel.org>; Mon, 17 Dec 2018 06:00:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
         d=janestreet.com; s=google;
         h=mime-version:references:in-reply-to:from:date:message-id:subject:to
          :cc;
         bh=019V1mpopS8WJr8aJzk2ltcywzun5LHzLWW2me9IeaE=;
         b=Q1QhirB4O/0f+w2W+SedMUISkga5TAJd7j5WWPmuBv2dQISm8qmDx3Zq8JSQoniydq
          R/kCrKfB0JTHT6/zNCrOqdXSe8fen7EVP9UkJrZ98a7ElDJ7ofForQx/+3j1nsS9GqME
          YN3PspKguuLQ3aKva65qWTFLu3UXMosRQy7hA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
         d=1e100.net; s=20161025;
         h=x-gm-message-state:mime-version:references:in-reply-to:from:date
          :message-id:subject:to:cc;
         bh=019V1mpopS8WJr8aJzk2ltcywzun5LHzLWW2me9IeaE=;
         b=mMfO5f7zRkCUslJ1n+vwtaizqPlNt2kDPiuKIZu1hQkyCNu+MYjDlB4Fqxll+JjqcF
          qwjlyR9f88rEEcemojugSNISzDKcz8RiT9Eaayw/MWUHP3+xXGeKdEq40B452p84GjlP
          LwXuuZSwyXSRw5bvXdD7M6dSuo1sU+zMvs/opN6OSOwJOXvAY1h6w2uubnG0utkaPFoD
          d7cLNY+r034yoDgRu/NYrBGX0HgYAuY9NomQPnbrmt0T8PTMRww0bFzaQsiAU991MftL
          maLEgyUh1S+uB5Bkhv0a/aGgRLZKTmUiVX4St92FE7mQcoPhnnuiLzbsRIKRa5VpLlbI
          WKbw==
X-Gm-Message-State: AA+aEWarekMJgKB8Xg9MQ39Ip0/4mjLTAAQW0CPekTRZhOi6TiriFuB4
        l4aDTKVHNxGewfVlbo139iKKTqqtNiwRSecfwxLwqgfU3Q+3CzSCvfzs1VEEi45qJEv65B643VQ
        rHzFyCCV2Nnfl2uKfYCowSbk/oroqQqi19Ic=
X-Received: by 2002:a24:eb0b:: with SMTP id h11mr12115556itj.138.1545055235204;
         Mon, 17 Dec 2018 06:00:35 -0800 (PST)
X-Google-Smtp-Source: AFSGD/USQvfWKbddzDTje+CUzwIO0bk7HgDUKibRRw//G8Ph6sDyR5GOiMggZvigq/zoC4M/oor+c/1+rj5CZHAINSA=
X-Received: by 2002:a24:eb0b:: with SMTP id h11mr12115527itj.138.1545055234848;
  Mon, 17 Dec 2018 06:00:34 -0800 (PST)
MIME-Version: 1.0
References: <20181216171933.2e4f5be6@canb.auug.org.au>
In-Reply-To: <20181216171933.2e4f5be6@canb.auug.org.au>
From:   Chris Perl <cperl@janestreet.com>
Date:   Mon, 17 Dec 2018 08:59:58 -0500
Message-ID: <CAAih9mj+u8Ec6=3K53_x8S-tHz_dXHORMfqZWsAnMS1WLzgz-w@mail.gmail.com>
Subject: Re: linux-next: Signed-off-by missing for commit in the nfs-anna tree
To:     Stephen Rothwell <sfr@canb.auug.org.au>
Cc:     Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-JS-Exim-Data-Received: 2018-12-17 09:00:35-0500
X-JS-Processed-by: mailcore
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Dec 16, 2018 at 1:19 AM Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Hi all,
> Commit
>
>   748d6fd8d297 ("NFS: nfs_compare_mount_options always compare auth flavors.")
>
> is missing a Signed-off-by from its author.

Whoops.  Sorry about that (I forgot to run it through checkpatch.pl).

Should I resend a fresh patch with the Signed-off-by included or is it
enough to just assert in this email that I wrote it and have the right
to pass it on?  If the latter is sufficient, then I do assert those
things.  If not, I'm happy to resend.
