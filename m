Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 030D1C282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 13:34:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CF92120820
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 13:34:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727659AbfDJNeI convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 09:34:08 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:36753 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727171AbfDJNeI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 09:34:08 -0400
Received: by mail-qt1-f195.google.com with SMTP id s15so2839589qtn.3
        for <linux-nfs@vger.kernel.org>; Wed, 10 Apr 2019 06:34:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=pt9vCpQy53rtW+xZ3gkUPbvHc7QXFmCcBUt6DawJJPc=;
        b=A5Waurk07RZlcml6IlT+t3ULIUNknOBgR/arFNTmVEFpbTJbbj6m+6BlKgnz5CuwAe
         1EjODKo7ilgKtmtjPqDe4w9E6fcK5naTqnk7Bz2dqXDRxsz75boMBjT63ska8TU1+mYZ
         GhQi2KokVc4xjuyLEQCMgdBw2fIwM/9onmmqKfmI7V9ojsbVd9ocMT8wo3G8jI2WVRAj
         D9GjY4gcjWeZgSvdyXWUEgWSI8xQMGx+8w0xOqEU/Xfpv0HC7WkxxDpP+ITNYQl/Yz1C
         oRyQ4PwXwqc+qF2iTjqS2ZHkuj0Nvl5KAZ2VbuiMx1yR4TkheLgnLE0tAgbClnx5xFR9
         RheA==
X-Gm-Message-State: APjAAAXuCVIC93377Ffy6uaVpj9UpUTMjrO+Dk+3OTBWkkThLMwZnFGJ
        pal90Z4UmGkkKJ6cTpNPC8donR/fN7M1sAlTF4uZOfAZ3VU=
X-Google-Smtp-Source: APXvYqwNeP7vSe9gvE/hV9FW6H81JqXijVxM9rB5CfRNcTtNbFlSTWzMXs6FolX20+QbWvQAaCzVPZeGbg1U4/+Hzhg=
X-Received: by 2002:ac8:1bba:: with SMTP id z55mr35583223qtj.354.1554903246666;
 Wed, 10 Apr 2019 06:34:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190326135740.16558-1-kdsouza@redhat.com> <20190409203427.GC29099@fieldses.org>
 <CAA_-hQ+fhGCiue4aGZiDtdHy1_grHCnSPa8q8-bMdnxE-PP=AA@mail.gmail.com> <20190410132607.GA2714@fieldses.org>
In-Reply-To: <20190410132607.GA2714@fieldses.org>
From:   Kenneth Dsouza <kdsouza@redhat.com>
Date:   Wed, 10 Apr 2019 19:03:54 +0530
Message-ID: <CAA_-hQKa0Am2T1xDw0RFOVg5FB__DJUDfFfsKZoeVns3QwD5DQ@mail.gmail.com>
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

Thanks! Should we also add the below entries similar to getfacl?

$ nfs4_getfacl /test/
# file: /test/
# owner: test
# group: test
A::OWNER@:rwaDxtTcCy
A::GROUP@:rwaDxtcy
A::EVERYONE@:rwaDxtcy

On Wed, Apr 10, 2019 at 6:56 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Wed, Apr 10, 2019 at 03:07:11PM +0530, Kenneth Dsouza wrote:
> > On Wed, Apr 10, 2019 at 2:04 AM J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > Thanks, applying with some fixes:
> > >
> > > On Tue, Mar 26, 2019 at 07:27:40PM +0530, Kenneth D'souza wrote:
> > > > With this patch the filename will not be printed.
> > > >
> > > >     $ nfs4_getfacl /test/
> > > >     # file: /test/
> > > >     A::OWNER@:rwaDxtTcCy
> > > >     A::GROUP@:rwaDxtcy
> > > >     A::EVERYONE@:rwaDxtcy
> > > >
> > > >     $ nfs4_getfacl -c /test/
> > > >
> > > >     A::OWNER@:rwaDxtTcCy
> > > >     A::GROUP@:rwaDxtcy
> > > >     A::EVERYONE@:rwaDxtcy
> > >
> > > I don't see any reason for that blank line, I've removed it.
> > >
> > I added the blank line so we print acl for each file on a new line
> > when -c is used.
>
> OK, it does make sense to have a blank line between multiple ACLs.
>
> Again I'd rather adopt the same behavior has getfacl/setfacl whenever we
> can.  Looks like getfacl just appends a blank line regardless of whether
> -c is used or whether the are multiple ACLs:
>
>         [bfields@patate ~]$ getfacl .
>         # file: .
>         # owner: bfields
>         # group: bfields
>         user::rwx
>         group::--x
>         other::--x
>
>         [bfields@patate ~]$
>
> I've added that to print_acl_from_path().
>
> --b.
>
> > # nfs4_getfacl -Rc /test
> >
> > A::OWNER@:rwaDxtTcCy
> > A::GROUP@:rwaDxtcy
> > A::EVERYONE@:rwaDxtcy
> >
> > A::OWNER@:rwatTcCy
> > A::GROUP@:tcy
> > A::EVERYONE@:tcy
> >
> > A::OWNER@:rwaDxtTcCy
> > A::GROUP@:rxtcy
> > A::EVERYONE@:rxtcy
> >
> >
> > > > @@ -115,7 +119,10 @@ static void print_acl_from_path(const char *fpath)
> > > >       struct nfs4_acl *acl;
> > > >       acl = nfs4_acl_for_path(fpath);
> > > >       if (acl != NULL) {
> > > > +             if(ignore_comment == 0)
> > > >               printf("\n# file: %s\n", fpath);
> > >
> > > This needs to be indented.
> > >
> > > > +             else
> > > > +                     printf("\n");
> > >
> > > I've removed the "else" clause.
> > >
> > > And fixed a couple minor whitespace issues.
> > >
> > > --b.
> > >
> > > >               nfs4_print_acl(stdout, acl);
> > > >               nfs4_free_acl(acl);
> > > >       }
> > > > @@ -125,7 +132,7 @@ static void usage(int label)
> > > >  {
> > > >       if (label)
> > > >               fprintf(stderr, "%s %s -- get NFSv4 file or directory access control lists.\n", execname, VERSION);
> > > > -     fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n", execname);
> > > > +     fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n  -c, --omit-header\tDo not display the comment header (Do not print filename)\n", execname);
> > > >  }
> > > >
> > > >  static void more_help()
> > > > --
> > > > 2.20.1
