Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.ugent.be ([157.193.49.126]:47168 "EHLO smtp2.UGent.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253Ab1GCN2s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Jul 2011 09:28:48 -0400
Message-ID: <4E106E91.8080208@debian.org>
Date: Sun, 03 Jul 2011 15:28:49 +0200
From: Luk Claes <luk@debian.org>
To: Jim Rees <rees@umich.edu>
CC: NeilBrown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not segfault because of kernel version
References: <1309617149-3993-1-git-send-email-luk@debian.org> <20110703150421.2db09d94@notabene.brown> <4E100E17.5000304@debian.org> <20110703130237.GA9889@merit.edu> <4E106A56.1050802@debian.org> <20110703132605.GC9889@merit.edu>
In-Reply-To: <20110703132605.GC9889@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/03/2011 03:26 PM, Jim Rees wrote:
> Luk Claes wrote:
> 
>   > You can't return -1 from a function returning unsigned int.  I think you
>   > want to return something like
>   > 
>   > MAKE_VERSION(9999, 255, 255)
>   
>   Would it not be better to return UINT_MAX in that case to avoid having
>   to change it when version 10000 would be released and to avoid overflows
>   that could potentially order lower?
> 
> Maybe.  I wanted the second and third numbers to be the max possible (255).
> But of course they will be anyway if you return UINT_MAX and are running on
> an architecture that represents ints in two's complement binary.  Which is
> the case today, but wasn't there a port of unix to the System 36 at one
> time?  Ok, that's just silly.
> 
> Yes, just return UINT_MAX.  Fix the other error return too, the one where
> uname fails.  And put in a comment if you can briefly summarize Linus's
> argument.

I thought that a real error like uname failing should still get the
'wrong' return 0, no?

Cheers

Luk
