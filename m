Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49318 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210AbaFWNj2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 09:39:28 -0400
Date: Mon, 23 Jun 2014 06:39:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 000/104] nfsd: eliminate the client_mutex
Message-ID: <20140623133926.GA32746@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

thanks for bringing this forward.  I've started looking at the series,
but I'm a little overwhelmed as it's growing bigger and bigger with
each posting.  That also makes me a little worried about putting all
of it into 3.17.  I know you've started separating a few bits out and
some of those actually went into 3.16, but maybe we really should
start to some easier to split piece in first and make sure they get
into 3.17 and then see if we can get through the rest of it in time.

Besides the obvious fixes for bits that were racy before and don't
just need better scalability one thing that strikes to mind are some
of the higher level logic changes, like the changes fixes to various
stateowner / stateid relations.

Besides that some higher level comments from glacing over the series:

 - the patches that touch locks.c and the lockdep code should go
   first, and include the maintainer (at least for lockdep, locks.c is
   easy :)) and relevant mailing lists.
 - lots of patches only have a subject line, but no explanation in the
   body at all.  While this might be enough for trivial patches few
   of them are trivial enough that this would be enough.
 - some patches have a signoff from Trond, but no From: line for him
   in the body.  I suspect this just got lost somewhere.
 - there is some confusion of NFSd vs nfsd in the subsystem prefixes.
   While it seems odd and against the usual naming NFSd seems to be
   the common one for nfs patches.

checkpatch.pl also has various valid complains (mostly about too long
lines) and a few silly ones about printks, might be worth to address
them.

Last but not least I get a new compiler warning with the whole series
applied, as put_client is only used by the fault injection code, but
still compiled when the config option for it is not set.

I hope I'll have some more useful detailed reviews soon.

