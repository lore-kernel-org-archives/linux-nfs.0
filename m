Return-Path: <SRS0=cy8Q=UM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACB50C31E45
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Jun 2019 15:06:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8629A21743
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Jun 2019 15:06:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732984AbfFMPGl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 13 Jun 2019 11:06:41 -0400
Received: from fieldses.org ([173.255.197.46]:52370 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732409AbfFMOIF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Jun 2019 10:08:05 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 221021D27; Thu, 13 Jun 2019 10:08:04 -0400 (EDT)
Date:   Thu, 13 Jun 2019 10:08:04 -0400
From:   "J . Bruce Fields" <bfields@fieldses.org>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Miklos Szeredi <miklos@szeredi.hu>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>
Subject: Re: [PATCH v2] locks: eliminate false positive conflicts for write
 lease
Message-ID: <20190613140804.GA2145@fieldses.org>
References: <20190612172408.22671-1-amir73il@gmail.com>
 <2851a6b983ed8b5b858b3b336e70296204349762.camel@kernel.org>
 <CAOQ4uxi-uEhAbqVeYbeqAR=TXpthZHdUKkaZJB7fy1TgdZObjQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxi-uEhAbqVeYbeqAR=TXpthZHdUKkaZJB7fy1TgdZObjQ@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jun 13, 2019 at 04:28:49PM +0300, Amir Goldstein wrote:
> On Thu, Jun 13, 2019 at 4:22 PM Jeff Layton <jlayton@kernel.org> wrote:
> > Looks good to me. Aside from the minor nit above:
> >
> >     Reviewed-by: Jeff Layton <jlayton@kernel.org>
> >
> > I have one file locking patch queued up for v5.3 so far, but nothing for
> > v5.2. Miklos or Bruce, if either of you have anything to send to Linus
> > for v5.2 would you mind taking this one too?
> >
> 
> Well. I did send a fix patch to Miklos for a bug introduced in v5.2-rc4,
> so...

I could take it.  I've modified it as below.

I'm very happy with the patch, but not so much with the idea of 5.2 and
stable.

It seems like a subtle change with some possibility of unintended side
effects.  (E.g. I don't think this is true any more, but my memory is
that for a long time the only thing stopping nfsd from giving out
(probably broken) write delegations was an extra reference that it held
during processing.) And if the overlayfs bug's been there since 4.19,
then waiting a little longer seems OK?

--b.

diff --git a/fs/locks.c b/fs/locks.c
index c7912b0fdeea..2056595751e8 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1779,7 +1779,7 @@ check_conflicting_open(struct file *filp, const long arg, int flags)
 	/* Make sure that only read/write count is from lease requestor */
 	if (filp->f_mode & FMODE_WRITE)
 		self_wcount = 1;
-	else if ((filp->f_mode & (FMODE_READ | FMODE_WRITE)) == FMODE_READ)
+	else if (filp->f_mode & FMODE_READ)
 		self_rcount = 1;
 
 	if (arg == F_WRLCK && (wcount != self_wcount ||
