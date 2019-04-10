Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1C1DC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 09:37:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C08D22083E
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 09:37:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728729AbfDJJhY convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 05:37:24 -0400
Received: from mail-qt1-f193.google.com ([209.85.160.193]:36998 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728563AbfDJJhX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 05:37:23 -0400
Received: by mail-qt1-f193.google.com with SMTP id z16so2049735qtn.4
        for <linux-nfs@vger.kernel.org>; Wed, 10 Apr 2019 02:37:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=yAQz5BLng5oyJQMHFT2xCaXJB7K9wltC4VVRtHovSh4=;
        b=KxzOTjh/SIq/ooWOTuHZmEKqXpwE0z76N6c5Xy9JdoiVu/0daOaq9igLrZiKK0eayu
         w7C5O/i4XDepAWu/4QXCiA4M3/+Y8EvXsvfJd27kLlCZrXI2KTZGKlaGv+e+U0JmFjbe
         IQH8Mky8Q95luw/Xsm+XAQcvJt1GTtdEoWwJkaR1yIg0mY5Qplgt2WClfq6pXLEfBKOE
         nT7VkpUCL8IfT4bBN5Qptwl9UhBvS1NS+CQNYawCvyZdxQbsCgLVkjB3EJbFr4X0b7Ux
         KlFVWVPoaGTWqpO2NKrCajsO3V3BeQltWjOuMJRz1pBGPBKu2bLgXjwou6qReWACkdjm
         COwg==
X-Gm-Message-State: APjAAAWekkd/ipzPHfbkKWDtr6jwPaBh0XZPbFdi93lA6Ffvr9daecku
        VubDrL5uHRP4pCCZjtQrM27luNQvYYFLPQ7kgKUZVA==
X-Google-Smtp-Source: APXvYqxcVmXxXVuEKWp+bvtA6Myt5HDZCm1fzZehEm3kTn+tZu+50/en3/4ElqZKJjj5dGpzMue09ch2AYaIgca+30Q=
X-Received: by 2002:aed:35e4:: with SMTP id d33mr34655188qte.58.1554889042672;
 Wed, 10 Apr 2019 02:37:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190326135740.16558-1-kdsouza@redhat.com> <20190409203427.GC29099@fieldses.org>
In-Reply-To: <20190409203427.GC29099@fieldses.org>
From:   Kenneth Dsouza <kdsouza@redhat.com>
Date:   Wed, 10 Apr 2019 15:07:11 +0530
Message-ID: <CAA_-hQ+fhGCiue4aGZiDtdHy1_grHCnSPa8q8-bMdnxE-PP=AA@mail.gmail.com>
Subject: Re: [PATCH] nfs4_getfacl: Add new option -c/--omit-header to not
 display comment header.
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Apr 10, 2019 at 2:04 AM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> Thanks, applying with some fixes:
>
> On Tue, Mar 26, 2019 at 07:27:40PM +0530, Kenneth D'souza wrote:
> > With this patch the filename will not be printed.
> >
> >     $ nfs4_getfacl /test/
> >     # file: /test/
> >     A::OWNER@:rwaDxtTcCy
> >     A::GROUP@:rwaDxtcy
> >     A::EVERYONE@:rwaDxtcy
> >
> >     $ nfs4_getfacl -c /test/
> >
> >     A::OWNER@:rwaDxtTcCy
> >     A::GROUP@:rwaDxtcy
> >     A::EVERYONE@:rwaDxtcy
>
> I don't see any reason for that blank line, I've removed it.
>
I added the blank line so we print acl for each file on a new line
when -c is used.
# nfs4_getfacl -Rc /test

A::OWNER@:rwaDxtTcCy
A::GROUP@:rwaDxtcy
A::EVERYONE@:rwaDxtcy

A::OWNER@:rwatTcCy
A::GROUP@:tcy
A::EVERYONE@:tcy

A::OWNER@:rwaDxtTcCy
A::GROUP@:rxtcy
A::EVERYONE@:rxtcy


> > @@ -115,7 +119,10 @@ static void print_acl_from_path(const char *fpath)
> >       struct nfs4_acl *acl;
> >       acl = nfs4_acl_for_path(fpath);
> >       if (acl != NULL) {
> > +             if(ignore_comment == 0)
> >               printf("\n# file: %s\n", fpath);
>
> This needs to be indented.
>
> > +             else
> > +                     printf("\n");
>
> I've removed the "else" clause.
>
> And fixed a couple minor whitespace issues.
>
> --b.
>
> >               nfs4_print_acl(stdout, acl);
> >               nfs4_free_acl(acl);
> >       }
> > @@ -125,7 +132,7 @@ static void usage(int label)
> >  {
> >       if (label)
> >               fprintf(stderr, "%s %s -- get NFSv4 file or directory access control lists.\n", execname, VERSION);
> > -     fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n", execname);
> > +     fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n  -c, --omit-header\tDo not display the comment header (Do not print filename)\n", execname);
> >  }
> >
> >  static void more_help()
> > --
> > 2.20.1
