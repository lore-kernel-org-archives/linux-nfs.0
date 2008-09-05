From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: fix nfs_parse_ip_address() corner case
Date: Fri, 5 Sep 2008 17:58:30 -0400
Message-ID: <20080905215830.GI12947@fieldses.org>
References: <20080903203414.3322.97607.stgit@tarkus.1015granger.net> <20080904202302.GD13981@fieldses.org> <76bd70e30809041436y4a8fc1d2hb8230cb7aba17f26@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46127 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751825AbYIEV6e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Sep 2008 17:58:34 -0400
In-Reply-To: <76bd70e30809041436y4a8fc1d2hb8230cb7aba17f26-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2008 at 05:36:17PM -0400, Chuck Lever wrote:
> On Thu, Sep 4, 2008 at 4:23 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Slightly irrelevant, but same comment as before--wouldn't it be easier
> > to follow the logic if instead of:
> >
> >        p = kstrndup(...)
> >        if (p) {
> >                do stuff for successful case
> >                ....
> >                return 1;
> >        }
> >
> >        return 0;
> >
> > it were:
> >
> >        p = kstrndup(...)
> >        if (!p)
> >                return 0;
> >        do stuff for successful case
> >        ...
> >        return 1;
> 
> I tried that.  It made this patch about 3x larger than it needed to
> be, obscured the changes introduced by the patch, and made it harder
> to show that the new logic is correct.  As we are not introducing new
> code here but repairing existing issues, such a clean up would need to
> be in a separate patch.

I agree.

> I generally prefer to use a structured language as it was intended,
> rather than to abuse "goto" as is the trend in the Linux kernel.

That's a well-established practice, not a trend, and in any case I
didn't add a goto.

> By creating named subroutines instead of using lambda functions

I don't see any difference over named subroutines here?  Does c even
support lambda functions?

To me the second example is obviously more readable, partly since it
helps clear up the return convention ("oh, we're returning 0 on failure
of kstrndup!  0 must mean failure..."), while the 1st delays one of the
two branches of the if longer than necessary.

But I don't care enough to insist.  Take it as an indicator of what'd be
clearer to me for code I have to read a lot, if you like.

--b.
