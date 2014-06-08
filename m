Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:37047 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722AbaFHSww (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jun 2014 14:52:52 -0400
Received: by mail-qg0-f42.google.com with SMTP id q107so8017535qgd.15
        for <linux-nfs@vger.kernel.org>; Sun, 08 Jun 2014 11:52:51 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 8 Jun 2014 14:52:49 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: WARN_ON_ONCE pop with tip of your nfsd-next branch
Message-ID: <20140608145249.2be6b75c@primarydata.com>
In-Reply-To: <20140608184436.GA437@fieldses.org>
References: <20140607215109.3cb5e368@tlielax.poochiereds.net>
	<20140608171723.GA32514@fieldses.org>
	<20140608184436.GA437@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 8 Jun 2014 14:44:36 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sun, Jun 08, 2014 at 01:17:23PM -0400, J. Bruce Fields wrote:
> > On Sat, Jun 07, 2014 at 09:51:09PM -0400, Jeff Layton wrote:
> > > Hi Bruce,
> > > 
> > > Just a heads up...
> > > 
> > > Was doing some testing with a pile of patches (mostly v4 state-related)
> > > on top of your nfsd-next branch, and saw this pop:
> > 
> > Do you know exactly was the commit id of the last commit from my branch?
> 
> Also, do you remember what sort of testing it was?
> 
> --b.

The tip was at a676de9e22b4c13c8d4a27289b1f2bcf35dce6dd. It looks like
maybe you rebased at some point though and now the commit IDs are
different? To make it pop, I ran fsstress on a v4.1 mount. I think it
was these options:

    $ fsstress -d <dir> -n 1000 -p 128

I'll see if I can make it happen again when I have some time for more
testing.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
