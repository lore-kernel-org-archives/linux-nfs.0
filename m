Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D85A4C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 09:28:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AC31C2083E
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 09:28:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728858AbfDJJ2Y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 05:28:24 -0400
Received: from mail-qk1-f195.google.com ([209.85.222.195]:46629 "EHLO
        mail-qk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727583AbfDJJ2X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 05:28:23 -0400
Received: by mail-qk1-f195.google.com with SMTP id s81so753864qke.13
        for <linux-nfs@vger.kernel.org>; Wed, 10 Apr 2019 02:28:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=IZ3JMAdJdYAEsidE92u9pHXM2/mv0kXsl+atefdC1Ug=;
        b=jBHnvP9nP1elHzzlvcEhMWq8GSnCIFNSJ2OnWmIzXywsTEnqR6W//GDs5lteROXF43
         t6s12Kqur+jRhibbKvJpmQiFLb3sj8SiHszTU4nlgb0PpFCbOvll2j2+wjaSiZxp46vq
         BbmCKKK0MsGGtqZzEMrt2ZnhiaPDXU7FvXLQrMC48q4SdJ76Wha+UcwOTixulxZEwT8p
         d09KP/kGVeVf9tGWrC1ljj7hyeJP8ijjL7ZnuoSQhZr3ggkZj0e+C+wQ77UC0jxbjqs0
         Hr1zsKUpbDeg7Vl31/1EM/VTE3LGN69fnJppwt2kBqOvyR4ERpBa0cV5LVlcs7hZlThK
         vCjA==
X-Gm-Message-State: APjAAAVGLnRjVCf4G+PR5Mrfd3ip69vz0rHPNMQUtOGAj/UAjM2B8LKZ
        54inK8uUX7W2shbUiZrWutc26wIz+qh716qPaqENE1Px
X-Google-Smtp-Source: APXvYqwVTAUfWyKNL0FQ0uiscTJ4BRvrWUL8uwqy6yx+KpNz96nR1I+xqQdX8OpDssoTj6voNt9xLlss3w2951yI3Og=
X-Received: by 2002:a37:6748:: with SMTP id b69mr32719146qkc.79.1554888502761;
 Wed, 10 Apr 2019 02:28:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190326141109.16844-1-kdsouza@redhat.com> <20190409205011.GD29099@fieldses.org>
In-Reply-To: <20190409205011.GD29099@fieldses.org>
From:   Kenneth Dsouza <kdsouza@redhat.com>
Date:   Wed, 10 Apr 2019 14:58:11 +0530
Message-ID: <CAA_-hQJhCgSVqRSiPzHPqhOoxMM9Bi=F3x=Hc0v6NBe=NeXf1A@mail.gmail.com>
Subject: Re: [PATCH] nfs4_setfacl: Skip comment field while reading ACE(s).
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks for taking care of this.

On Wed, Apr 10, 2019 at 2:20 AM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> Applied, with some fixes:
>
> On Tue, Mar 26, 2019 at 07:41:09PM +0530, Kenneth D'souza wrote:
> > With commit 6630629bb661a7f48fb9856f7fd9616ce1499efa an additional field for filename
> > was added due to which nfs4_setfacl failed to handle comments while reading ACE(s)
> > from nfs4_getfacl output.
> > This patch resolves the issue by skipping comment header.
> >
> >  With fix:
> >
> >  $ nfs4_setfacl --test -s "$(nfs4_getfacl  file1)" file2
> >  Skipping comment # file: file1
>
> Just skip it silently, there's not need to print anything.
>
> >  ## Test mode only - the resulting ACL for "/test/file2":
> >  A::OWNER@:rwatTcCy
> >  A:g:GROUP@:rtcy
> >  A::EVERYONE@:rtcy
> >
> >  Without fix:
> >
> >  $ nfs4_setfacl --test -s "$(nfs4_getfacl  file1)" file2
> >  Failed while inserting ACE(s).
> >
> > Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
> > ---
> >  libnfs4acl/nfs4_insert_string_aces.c | 16 ++++++++++------
> >  1 file changed, 10 insertions(+), 6 deletions(-)
> >
> > diff --git a/libnfs4acl/nfs4_insert_string_aces.c b/libnfs4acl/nfs4_insert_string_aces.c
> > index 5a482d5..50b7bbf 100644
> > --- a/libnfs4acl/nfs4_insert_string_aces.c
> > +++ b/libnfs4acl/nfs4_insert_string_aces.c
> > @@ -45,21 +45,25 @@ int nfs4_insert_string_aces(struct nfs4_acl *acl, const char *acl_spec, unsigned
> >       if ((s = sp = strdup(acl_spec)) == NULL)
> >               goto out_failed;
> >
> > +
> >       while ((ssp = strsep(&sp, ",\t\n\r")) != NULL) {
> >               if (!strlen(ssp))
> >                       continue;
> >
> > -             if ((ace = nfs4_ace_from_string(ssp, acl->is_directory)) == NULL)
> > -                     goto out_failed;
> > +             if(*ssp == '#')
> > +                     printf("Skipping comment %s\n", ssp);
>
> So let's just do a "continue" here, as above.  Also notice we usually
> leave a space after "if".
>
> --b.
>
> > +             else {
> > +                     if ((ace = nfs4_ace_from_string(ssp, acl->is_directory)) == NULL)
> > +                             goto out_failed;
> >
> > -             if (nfs4_insert_ace_at(acl, ace, index++)) {
> > -                     free(ace);
> > -                     goto out_failed;
> > +                     if (nfs4_insert_ace_at(acl, ace, index++)) {
> > +                             free(ace);
> > +                             goto out_failed;
> > +                     }
> >               }
> >       }
> >       if (acl->naces == 0)
> >               goto out_failed;
> > -
> >  out:
> >       if (s)
> >               free(s);
> > --
> > 2.20.1
