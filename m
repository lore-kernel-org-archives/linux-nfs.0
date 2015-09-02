Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40800 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060AbbIBTUK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Sep 2015 15:20:10 -0400
Date: Wed, 2 Sep 2015 15:20:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Subject: Re: [RFC v6 02/40] vfs: Add MAY_CREATE_FILE and MAY_CREATE_DIR
 permission flags
Message-ID: <20150902192008.GB3319@fieldses.org>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
 <1438689218-6921-3-git-send-email-agruenba@redhat.com>
 <20150902185300.GA3319@fieldses.org>
 <CAHc6FU62LQ8xnEbjsBprnud36AURg_ggifFoHOVM51-9vRJeDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU62LQ8xnEbjsBprnud36AURg_ggifFoHOVM51-9vRJeDg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 02, 2015 at 09:06:32PM +0200, Andreas Gruenbacher wrote:
> 2015-09-02 20:53 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> >> @@ -453,7 +453,8 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
> >>   * this, letting us set arbitrary permissions for filesystem access without
> >>   * changing the "normal" UIDs which are used for other things.
> >>   *
> >> - * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
> >> + * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
> >> + * MAY_WRITE must also be set in @mask.
> >
> > Why?
> 
> So that file systems that don't support MAY_APPEND can ignore the flag
> and will then automatically check for MAY_WRITE instead.

Got it.  And maybe it should be obvious, but it might be worth a
sentence in the changelog if it's not already explained elsewhere.--b.

> 
> > (Also: written as a simple list like that, it's a ambiguous how to
> > parse that comment: I think you mean that MAY_WRITE must be set whenever
> > MAY_APPEND, MAY_CREATE_FILE, or MAY_CREATE_DIR are set.)
> 
> Yes, that's better.
> 
> Thanks,
> Andreas
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
