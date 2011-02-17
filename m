Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56691 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754051Ab1BQEv0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 23:51:26 -0500
Date: Wed, 16 Feb 2011 23:51:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 2.6.38 nfsd bugfixes
Message-ID: <20110217045125.GI14534@fieldses.org>
References: <20110215185902.GG29420@fieldses.org>
 <20110217042519.GH14534@fieldses.org>
 <AANLkTikeK77v7y346-OX9dvufJSjbJ7qQSpJc4C3wLrZ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <AANLkTikeK77v7y346-OX9dvufJSjbJ7qQSpJc4C3wLrZ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 16, 2011 at 08:32:06PM -0800, Linus Torvalds wrote:
> On Wed, Feb 16, 2011 at 8:25 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > -               if ((host_err = nfsd_map_name_to_uid(argp->rqstp, buf, dummy32, &iattr->ia_uid)))
> > -                       goto out_nfserr;
> > +               if ((status = nfsd_map_name_to_uid(argp->rqstp, buf, dummy32, &iattr->ia_uid)))
> > +                       return status;
> 
> Btw, can we please just agree to not doing those idiotic double parenthesis?

Fine by me; I don't write new code that way.

I already committed it like that, so would rather just do any cleanup as
another patch for the next merge window; but let me know what you want.

--b.

> 
> There is a really trivial solution to the gcc warning - write your
> code like a sane person, instead of some ex-LISP hacker that has
> withdrawal symptoms. IOW, the above should be written as
> 
>   status = nfsd_map_name_to_uid(argp->rqstp, buf, dummy32, &iattr->ia_uid);
>   if (status)
>     return status;
> 
> which is a hell of a lot more readable, no?
> 
> There is never any real excuse to put an assignment inside a regular
> if-statement.
> 
> Inside a while/for loop? Sure. There are real syntactic reasons for
> doing things like
> 
>    while ((c = getchar()) != EOF) {
>    }
> 
> that actually make the code better and denser and avoid extra control
> flow crap or duplicate code.
> 
> Inside a macro expansion? Again, there may be good reasons to try to
> make it a single statement.
> 
> But a simple if-statement? There just isn't any reason for it, since
> the obvious thing is to just write it as two separate statements: the
> assignment, and the if-statement. So why do it and make the code
> uglier and harder to parse?
> 
>                                    Linus
