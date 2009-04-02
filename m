From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 16/47] nfsd41: match clientid establishment method
Date: Wed, 1 Apr 2009 20:01:27 -0400
Message-ID: <20090402000127.GK8899@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229137-10764-1-git-send-email-bhalevy@panasas.com> <20090331030418.GC7653@fieldses.org> <49D1D901.5000706@panasas.com> <3BDF03B5-9772-49DA-82D9-5D2CF70CC501@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44131 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716AbZDBABg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 20:01:36 -0400
In-Reply-To: <3BDF03B5-9772-49DA-82D9-5D2CF70CC501@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2009 at 10:10:48AM -0400, Andy Adamson wrote:
> On Mar 31, 2009, at 4:49 AM, Benny Halevy wrote:
>> At any rate, if this is something we need to fix for 4.1
>> and it does not introduce any regression to 4.0, and if
>> the fix isn't trivial/simple, I suggest we add a FIXME comment,
>> and add it to our todo list to defer the solution post
>> this push effort.

OK, apologies, it's just takes me much too long to catch up with all of
you, and make sure I understand these patches.

And I'm conflicted.

On the one hand, submission-time gives a really clear point at which to
do review and handle any problems found.  I'm a little worried that some
problems will be forgotten once the code is in.

On the other hand, there's a lot of 4.1 development going on and it
would be better to see it happening in mainline than out.  I don't see
any more v2/v3/v4.0 regressions, and people in general seem willing to
track and respond to comments.

On the other other hand, I do at least want to reassure myself that this
is a reasonable basis for further development.

I'd like to put off the callback stuff for now, at least: the addition
of a mutex held over the callbacks worries me, and interferes with an
ongoing attempt to make all the callback code asynchronous.  And I
haven't tried to review the rpc-level code there yet (and haven't seen
review of it from Trond).

Would it be possible to get one last revison of the patch series which
stops short of the callback stuff (so, the first 32 patches or so), and
fixes the trivial-to-fix stuff?  And would it be possible to do that by
(ulp) tomorrow?

--b.
