Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:28286 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754009Ab1F2SXZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2011 14:23:25 -0400
From: <peter.staubach@emc.com>
To: <tdh@excfb.com>
CC: <SteveD@redhat.com>, <linux-nfs@vger.kernel.org>
Date: Wed, 29 Jun 2011 14:16:24 -0400
Subject: RE: [PATCH 1/1] Remove warnings on various platforms
Message-ID: <5E6794FC7B8FCA41A704019BE3C70E8B8285F3CB@MX31A.corp.emc.com>
References: <y> <1309299723-31539-2-git-send-email-tdh@excfb.com>
 <5E6794FC7B8FCA41A704019BE3C70E8B8285F299@MX31A.corp.emc.com>
 <20110629172858.GA6258@adept.internal.excfb.com>
In-Reply-To: <20110629172858.GA6258@adept.internal.excfb.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hmmm.  Yes, make sense.

That said, I think that it would be better to attempt to do it the right way and then let people tell us when it isn't quite right yet.  We should eventually be able to come to a set of changes which are right, for everyone.

Compiling on Linux, Solaris, and FreeBSD should be a good start.  Perhaps Olga or someone else could help with the Windows compiles.  I suspect that we could find someone with access to AIX or HP/UX or ...  :-)

Perhaps we could also consider cleaning up tests.init?  The lists of commented out options seems quite unwieldly to me.  Do we really need all of that stuff, especially for the much older systems?

	Thanx...

		ps


-----Original Message-----
From: Tom Haynes [mailto:tdh@excfb.com] 
Sent: Wednesday, June 29, 2011 1:29 PM
To: Staubach, Peter
Cc: tdh@excfb.com; SteveD@redhat.com; linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] Remove warnings on various platforms

On Wed, Jun 29, 2011 at 07:53:19AM -0400, peter.staubach@emc.com wrote:
> Hi.
> 
> For some of these new casts, wouldn't be it better to simply declare the variable to be the correct type to start with instead of casting some other type?  For example, the socklen_t variables?
> 
> It seems funny that all of those XDR routines need to be casted as well.
> 
> 	Thanx...
> 
> 		ps

I tried to go with the most innocent changes I could. My main concern
is lack of access to different platforms to do sanity compiles
and unit testing.

-- 
Tom Haynes
ex-cfb

