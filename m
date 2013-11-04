Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab3KDB0r convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Nov 2013 20:26:47 -0500
Date: Sun, 3 Nov 2013 20:28:52 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>, steved@redhat.com
Subject: Re: [PATCH] nfs: set security label when revalidating inode
Message-ID: <20131103202852.7bcb62fe@corrin.poochiereds.net>
In-Reply-To: <37FC8791-6CAF-4852-ADEF-0CF3497FD3CA@netapp.com>
References: <1383389838-1858-1-git-send-email-jlayton@redhat.com>
	<C85EF88C-B4F8-484C-A00D-5A86ACB61C10@netapp.com>
	<20131103051438.3a4db316@tlielax.poochiereds.net>
	<20131103060145.73443e75@tlielax.poochiereds.net>
	<32FF43CF-D4D7-41AD-9B2F-8BAD6C2F846C@netapp.com>
	<20131103120130.68430d53@tlielax.poochiereds.net>
	<37FC8791-6CAF-4852-ADEF-0CF3497FD3CA@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 3 Nov 2013 18:41:43 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> 
> On Nov 3, 2013, at 12:01, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Sun, 3 Nov 2013 16:40:12 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > 
> >> 
> >> On Nov 3, 2013, at 6:01, Jeff Layton <jlayton@redhat.com<mailto:jlayton@redhat.com>> wrote:
> >> 
> >> On Sun, 3 Nov 2013 05:14:38 -0500
> >> Jeff Layton <jlayton@redhat.com<mailto:jlayton@redhat.com>> wrote:
> >> 
> >> On Sun, 3 Nov 2013 02:23:29 +0000
> >> "Myklebust, Trond" <Trond.Myklebust@netapp.com<mailto:Trond.Myklebust@netapp.com>> wrote:
> >> 
> >> 
> >> On Nov 2, 2013, at 6:57, Jeff Layton <jlayton@redhat.com<mailto:jlayton@redhat.com>> wrote:
> >> 
> >> Currently, we fetch the security label when revalidating an inode's
> >> attributes, but don't apply it. This is in contrast to the readdir()
> >> codepath where we do apply label changes.
> >> 
> >> OK. Why should we not just throw out the code that fetches the security label here?
> >> 
> >> IOW: what is the caching model that is being implemented in this patch; is it just “fetch label at random intervals” or is there real method to the madness?
> >> 
> >> Trond
> >> 
> >> I think that we should apply the new security label as soon as we
> >> realize that it has changed. Why should we treat the security label
> >> differently from any other inode attribute (e.g. ownership or mode)?
> >> 
> >> 
> >> Ok, I think I understand what you're getting at now that I've had a cup
> >> of coffee ;)
> >> 
> >> I guess you're pointing out a problem with the overall model, given that
> >> the current implementation doesn't send anything in the RPC to denote
> >> the security context of the client's task?
> >> 
> >> It's a fair point, and not one I have a great answer for. I think that
> >> you're correct that for the most part that they won't change. But when
> >> they do, what's to be gained by ignoring that?
> >> 
> >> They'll never be permanent anyway...as soon as the inode gets tossed
> >> out of the cache or the client reboots then you'll see the change on
> >> the next access of it.
> >> 
> >> I’m not saying that we must ignore changes, I’m saying that nobody else, so far, has been willing to step up and propose a model for how these things are supposed to change.
> >> 
> >> All I’ve heard has been that “a polling model would be better because labels can change”. OK, but a polling model has a number of adjustable parameters; the frequency of polling being the most obvious. I want someone to explain to me, based on how we expect labels to change, how those parameters need to be set.
> >> If the expectation is that they will change once in a lifetime (just after file creation), then that would justify trying to poll once or twice, but it does not justify polling for the entire lifetime of the file. Perhaps a better solution would be to just have the server change the NFS filehandle (e.g. by bumping the generation counter)?
> >> 
> > 
> > Ugh...that sounds ugly and prone to cause ESTALE errors. 
> > 
> > I don't think we can make any assumption on how they will change, any
> > more than we do for something like the ownership or mode. It comes down
> > to an action by an administrator, and people are notoriously
> > unpredictable.
> 
> ???? You’re saying that people choose security policies on a whim?
> 
> > Maybe this is a naive question, but...why treat this differently from
> > any other inode attribute?
> 
> That’s another “What if we were to do X?” question. Please see above.
> 

I'm not sure I can answer that. Perhaps Dave or Steve D. can clarify
that, or direct us toward someone who can?

I had been operating under the assumption that the security label was
basically an inode attribute like any other, and therefore we should
treat it like we do any other attribute in the cache.

I'm a little unclear on what you've been suggesting however. Are you
saying that we should be setting it only on I_NEW inodes? IOW, rip out
all of the places where we set the label aside from nfs_fhget?

-- 
Jeff Layton <jlayton@redhat.com>
