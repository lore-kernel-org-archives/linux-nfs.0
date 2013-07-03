Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754218Ab3GCAMU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jul 2013 20:12:20 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20130703093815.006437fd5f18210b7729b060@canb.auug.org.au>
References: <20130703093815.006437fd5f18210b7729b060@canb.auug.org.au> <6302.1372775256@warthog.procyon.org.uk>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: dhowells@redhat.com, torvalds@linux-foundation.org,
        linux-cachefs@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, milosz@adfin.com
Subject: Re: [GIT PULL] Fix assorted FS-Cache issues
Date: Wed, 03 Jul 2013 01:12:13 +0100
Message-ID: <4578.1372810333@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> >   git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/fscache-20130702
> 
> /me wonders where this has been hiding for the last month and a half ...

I asked you to pull my fscache branch on the 23rd May, and you replied on the
27th May saying you'd done so.

Looking in next-20130531 and next-20130527 in linux-next:

	+fscache                ccce57fed1ffb98ad4ff7c290276ca266435ad19

Looking in next-20130603 and next-20130701, I see:

	+fscache		bbd645c7a7b56f170940e81335ba4549f50aae95

in the Next/SHA1s file.  This is the same as the fscache-20130619 tag that I
emplaced today, though the fscache _branch_ you've been pulling had been at
that point for over a month (not yet a month and a half, I will admit).  git
request-pull seems to pick up tags in preference to branch points.

Comparing fscache-20130619 to fscache-20130702 shows:

	warthog>git diff fscache-20130619 fscache-20130702 | wc -l
	0

The only difference being in the descriptions (additional Acked-by lines).

I picked 19th June for the old tag name because that was the date I added in
the Acked-by lines, so this pins the point just before that.  In retrospect, I
should've used the commit date on the last patch.

As for public mailing lists, most of my patches have been presented as a set
on several such (fsdevel, nfs, cachefs and lkml) a couple of times (3rd May,
10th May).

David
