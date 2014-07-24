Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay0222.hostedemail.com ([216.40.44.222]:49432 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757637AbaGXQf0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jul 2014 12:35:26 -0400
Message-ID: <1406219722.27221.46.camel@joe-AO725>
Subject: Re: [PATCH 9/9] fs: dlm: lockd: Convert int result to unsigned char
 type
From: Joe Perches <joe@perches.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        David Teigland <teigland@redhat.com>,
        Christine Caulfield <ccaulfie@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        cluster-devel@redhat.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date: Thu, 24 Jul 2014 09:35:22 -0700
In-Reply-To: <20140724122445.2ebd1b23@tlielax.poochiereds.net>
References: <cover.1405879494.git.joe@perches.com>
	 <65b9ba0dba9c79a938267d5bed7ed0a8211e89ed.1405879494.git.joe@perches.com>
	 <20140723141139.2cf90cb0@tlielax.poochiereds.net>
	 <1406174039.2755.71.camel@joe-AO725>
	 <20140724122445.2ebd1b23@tlielax.poochiereds.net>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-07-24 at 12:24 -0400, Jeff Layton wrote:
> On Wed, 23 Jul 2014 20:53:59 -0700 Joe Perches <joe@perches.com> wrote:
> > On Wed, 2014-07-23 at 14:11 -0400, Jeff Layton wrote:
> > > On Sun, 20 Jul 2014 11:23:43 -0700 Joe Perches <joe@perches.com> wrote:
> > > > op->info.rv is an s32, but it's only used as a u8.
> > > I don't understand this patch. info.rv is s32 (and I assume that "rv"
> > > stands for "return value").
> > 
> > In this case it's not a return value but an input.
[]
> Well, it's an input into the lm_grant callback, but it originally comes
> in the downcall from userland (AFAICT). In this case, I'm referring to
[]
> It's been a while since I've looked over the lockd code, but I believe
> it's just a flag that indicates whether there is still a conflict
> between the block and the lock on the file.

Yes, that is how it is used.

> I don't think that patch will break anything. I just don't see it as an
> improvement on what's already there.
> 
> The rationale for this is lost in antiquity, but I think the basic idea
> was that you're either granting or updating the block based on the
> _result_ from some check for a lock conflict. While "result" as a name
> is a little confusing, "type" is even more so, IMO.
> 
> If you're hell-bent on changing this, then my suggestion would be
> to turn it into a bool and call it "conflict" or something similar. If
> you do decide to do that, adding some helpful kerneldoc comments would
> be a nice improvement too.

I hope I'm never hell-bent on patches.

I do prefer easier to read, clear code and I agree
that using it as a bool would make the code better.

I'll see about kernel-doc changes too.

cheers, Joe

