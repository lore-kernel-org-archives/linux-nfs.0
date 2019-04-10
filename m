Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9676FC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 13:26:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6D4A32070D
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 13:26:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731777AbfDJN0I (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 09:26:08 -0400
Received: from fieldses.org ([173.255.197.46]:59950 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730060AbfDJN0H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 Apr 2019 09:26:07 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 762157CB; Wed, 10 Apr 2019 09:26:07 -0400 (EDT)
Date:   Wed, 10 Apr 2019 09:26:07 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Kenneth Dsouza <kdsouza@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs4_getfacl: Add new option -c/--omit-header to not
 display comment header.
Message-ID: <20190410132607.GA2714@fieldses.org>
References: <20190326135740.16558-1-kdsouza@redhat.com>
 <20190409203427.GC29099@fieldses.org>
 <CAA_-hQ+fhGCiue4aGZiDtdHy1_grHCnSPa8q8-bMdnxE-PP=AA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_-hQ+fhGCiue4aGZiDtdHy1_grHCnSPa8q8-bMdnxE-PP=AA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Apr 10, 2019 at 03:07:11PM +0530, Kenneth Dsouza wrote:
> On Wed, Apr 10, 2019 at 2:04 AM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > Thanks, applying with some fixes:
> >
> > On Tue, Mar 26, 2019 at 07:27:40PM +0530, Kenneth D'souza wrote:
> > > With this patch the filename will not be printed.
> > >
> > >     $ nfs4_getfacl /test/
> > >     # file: /test/
> > >     A::OWNER@:rwaDxtTcCy
> > >     A::GROUP@:rwaDxtcy
> > >     A::EVERYONE@:rwaDxtcy
> > >
> > >     $ nfs4_getfacl -c /test/
> > >
> > >     A::OWNER@:rwaDxtTcCy
> > >     A::GROUP@:rwaDxtcy
> > >     A::EVERYONE@:rwaDxtcy
> >
> > I don't see any reason for that blank line, I've removed it.
> >
> I added the blank line so we print acl for each file on a new line
> when -c is used.

OK, it does make sense to have a blank line between multiple ACLs.

Again I'd rather adopt the same behavior has getfacl/setfacl whenever we
can.  Looks like getfacl just appends a blank line regardless of whether
-c is used or whether the are multiple ACLs:

	[bfields@patate ~]$ getfacl .
	# file: .
	# owner: bfields
	# group: bfields
	user::rwx
	group::--x
	other::--x
	
	[bfields@patate ~]$

I've added that to print_acl_from_path().

--b.

> # nfs4_getfacl -Rc /test
> 
> A::OWNER@:rwaDxtTcCy
> A::GROUP@:rwaDxtcy
> A::EVERYONE@:rwaDxtcy
> 
> A::OWNER@:rwatTcCy
> A::GROUP@:tcy
> A::EVERYONE@:tcy
> 
> A::OWNER@:rwaDxtTcCy
> A::GROUP@:rxtcy
> A::EVERYONE@:rxtcy
> 
> 
> > > @@ -115,7 +119,10 @@ static void print_acl_from_path(const char *fpath)
> > >       struct nfs4_acl *acl;
> > >       acl = nfs4_acl_for_path(fpath);
> > >       if (acl != NULL) {
> > > +             if(ignore_comment == 0)
> > >               printf("\n# file: %s\n", fpath);
> >
> > This needs to be indented.
> >
> > > +             else
> > > +                     printf("\n");
> >
> > I've removed the "else" clause.
> >
> > And fixed a couple minor whitespace issues.
> >
> > --b.
> >
> > >               nfs4_print_acl(stdout, acl);
> > >               nfs4_free_acl(acl);
> > >       }
> > > @@ -125,7 +132,7 @@ static void usage(int label)
> > >  {
> > >       if (label)
> > >               fprintf(stderr, "%s %s -- get NFSv4 file or directory access control lists.\n", execname, VERSION);
> > > -     fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n", execname);
> > > +     fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n  -c, --omit-header\tDo not display the comment header (Do not print filename)\n", execname);
> > >  }
> > >
> > >  static void more_help()
> > > --
> > > 2.20.1
