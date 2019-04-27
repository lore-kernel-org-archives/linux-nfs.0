Return-Path: <SRS0=TJwb=S5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 310A6C4321A
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Apr 2019 19:00:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0150C2087E
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Apr 2019 19:00:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725995AbfD0TAj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Apr 2019 15:00:39 -0400
Received: from fieldses.org ([173.255.197.46]:55336 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725921AbfD0TAi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 27 Apr 2019 15:00:38 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 09B751CC9; Sat, 27 Apr 2019 15:00:38 -0400 (EDT)
Date:   Sat, 27 Apr 2019 15:00:38 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.com>
Cc:     Andreas Dilger <adilger@dilger.ca>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        James Simmons <uja.ornl@gmail.com>
Subject: Re: [PATCH 00/10] exposing knfsd opens to userspace
Message-ID: <20190427190038.GB9568@fieldses.org>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
 <B37B2837-E8C8-41EA-9A2D-3F8B93304FDD@dilger.ca>
 <87lfzx65ax.fsf@notabene.neil.brown.name>
 <60EB550C-B79C-4DB4-AE3D-F1FCEB49EDA1@dilger.ca>
 <20190426125611.GA23112@fieldses.org>
 <87imv05nkk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87imv05nkk.fsf@notabene.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Apr 27, 2019 at 09:55:23AM +1000, NeilBrown wrote:
> On Fri, Apr 26 2019, J. Bruce Fields wrote:
> > But it's true that from the start nfsd didn't really fit the model
> > of a single (possibly writeable) attribute per file.
> 
> Depends on what you mean by that.  Original files where write-only and
> where slightly complex attributes.

Yes I thought it was just those too, but then I looked at the original
commit it also included at least the "exports" file.

> Writing performed an action, like
> adding an entry to the export table (first you add a client, then add a
> client+filesystem to export it).
> 
> This idea for a file performing an action, rather than presenting an
> attribute, is much the same as the "bind" and "unbind" files you can
> find in sysfs.
> 
> (see also https://lwn.net/Articles/378884/ for examples of sysfs files
> that are not one-attribute-per-file)

I'll give that a re-read, thanks.

I did spend maybe a few minutes looking into basing nfsd code on kernfs
and didn't think it was worth it.  I could take a more serious look.

--b.
