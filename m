From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 16/47] nfsd41: match clientid establishment method
Date: Thu, 02 Apr 2009 10:22:00 +0300
Message-ID: <49D46798.6080500@panasas.com>
References: <49CDDFC2.4070402@panasas.com> <1238229137-10764-1-git-send-email-bhalevy@panasas.com> <20090331030418.GC7653@fieldses.org> <49D1D901.5000706@panasas.com> <3BDF03B5-9772-49DA-82D9-5D2CF70CC501@netapp.com> <20090402000127.GK8899@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15595 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753092AbZDBHX3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 03:23:29 -0400
In-Reply-To: <20090402000127.GK8899@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 02, 2009, 3:01 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Tue, Mar 31, 2009 at 10:10:48AM -0400, Andy Adamson wrote:
>> On Mar 31, 2009, at 4:49 AM, Benny Halevy wrote:
>>> At any rate, if this is something we need to fix for 4.1
>>> and it does not introduce any regression to 4.0, and if
>>> the fix isn't trivial/simple, I suggest we add a FIXME comment,
>>> and add it to our todo list to defer the solution post
>>> this push effort.
> 
> OK, apologies, it's just takes me much too long to catch up with all of
> you, and make sure I understand these patches.
> 
> And I'm conflicted.
> 
> On the one hand, submission-time gives a really clear point at which to
> do review and handle any problems found.  I'm a little worried that some
> problems will be forgotten once the code is in.
> 
> On the other hand, there's a lot of 4.1 development going on and it
> would be better to see it happening in mainline than out.  I don't see
> any more v2/v3/v4.0 regressions, and people in general seem willing to
> track and respond to comments.
> 
> On the other other hand, I do at least want to reassure myself that this
> is a reasonable basis for further development.

Absolutely.  I was just trying to set the focus on the top priority, IMO:
flushing out the interaction with v4.0 and making sure there are no
regressions. I know that the v4.1 code is far from being perfect, even
with respect to the spec and I like your idea of at least documenting what
we have and what we don't, and what needs fixing.

As you said, keeping the code out of tree doesn't make it any
easier to fix or maintain so getting the new code in, in spite
of possible flaws with the *new* functionality as long as it's in a good
enough shape as a starting point, can just accelerate its development.

> 
> I'd like to put off the callback stuff for now, at least: the addition
> of a mutex held over the callbacks worries me, and interferes with an
> ongoing attempt to make all the callback code asynchronous.  And I
> haven't tried to review the rpc-level code there yet (and haven't seen
> review of it from Trond).

Understood.

> 
> Would it be possible to get one last revison of the patch series which
> stops short of the callback stuff (so, the first 32 patches or so), and
> fixes the trivial-to-fix stuff?  And would it be possible to do that by
> (ulp) tomorrow?

I'm on it.

Benny

> 
> --b.
