Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:62522 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285AbaFWN4s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 09:56:48 -0400
Received: by mail-qa0-f45.google.com with SMTP id v10so5520762qac.4
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 06:56:47 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 23 Jun 2014 09:56:45 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 000/104] nfsd: eliminate the client_mutex
Message-ID: <20140623095645.1fc23e9c@tlielax.poochiereds.net>
In-Reply-To: <20140623133926.GA32746@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<20140623133926.GA32746@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jun 2014 06:39:26 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> Hi Jeff,
> 
> thanks for bringing this forward.  I've started looking at the series,
> but I'm a little overwhelmed as it's growing bigger and bigger with
> each posting.  That also makes me a little worried about putting all
> of it into 3.17.  I know you've started separating a few bits out and
> some of those actually went into 3.16, but maybe we really should
> start to some easier to split piece in first and make sure they get
> into 3.17 and then see if we can get through the rest of it in time.
> 

Thanks for taking a look. The big problem with breaking this set up is
that it will likely result in at least some performance regression in
the interim. We're adding more granular locking inside of the
coarse-grained client_mutex, which is likely to mean at least some
slowdown until the client_mutex is removed. Maybe that's worth it
though.

> Besides the obvious fixes for bits that were racy before and don't
> just need better scalability one thing that strikes to mind are some
> of the higher level logic changes, like the changes fixes to various
> stateowner / stateid relations.
> 

I'll have to think about how to break those out. Unfortunately, there
are strong dependencies between some of those changes, which makes it
hard to do this in pieces.

> Besides that some higher level comments from glacing over the series:
> 
>  - the patches that touch locks.c and the lockdep code should go
>    first, and include the maintainer (at least for lockdep, locks.c is
>    easy :)) and relevant mailing lists.

Fair enough. I meant to cc the lockdep folks on the
lockdep_assert_not_held patch. I don't expect pushback from them, but
you're correct that they should be Cc'ed.

>  - lots of patches only have a subject line, but no explanation in the
>    body at all.  While this might be enough for trivial patches few
>    of them are trivial enough that this would be enough.

Ok. I'll try to flesh them out for the next posting.

>  - some patches have a signoff from Trond, but no From: line for him
>    in the body.  I suspect this just got lost somewhere.

Yeah. Some of them were originally written by Trond, but then I ended
up having to do large scale rework of them. I prob should have just
dropped his SOB lines from those. I'll go over those and do that or fix
the From: lines.

>  - there is some confusion of NFSd vs nfsd in the subsystem prefixes.
>    While it seems odd and against the usual naming NFSd seems to be
>    the common one for nfs patches.
> 

I tend to prefer "nfsd", but ok -- "NFSd" it is.

> checkpatch.pl also has various valid complains (mostly about too long
> lines) and a few silly ones about printks, might be worth to address
> them.
> 

Ahh right. I need to fix those -- Steve French reported a few of those
too (and sent me patches privately).

> Last but not least I get a new compiler warning with the whole series
> applied, as put_client is only used by the fault injection code, but
> still compiled when the config option for it is not set.
> 

Good catch. I'll fix that.

> I hope I'll have some more useful detailed reviews soon.
> 

Thanks. I should also note that a couple of races were found in the
nfs4_ol_stateid handling while testing this set, so I'll be respinning
it to fix those up anyway.

-- 
Jeff Layton <jlayton@primarydata.com>
