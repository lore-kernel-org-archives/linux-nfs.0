Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53218 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781Ab3DZRQl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Apr 2013 13:16:41 -0400
Date: Fri, 26 Apr 2013 13:16:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Malte =?utf-8?B?U2NocsO2ZGVy?= <maltesch@gmx.de>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS4 sec=krb5 broken in 3.9-rc8
Message-ID: <20130426171640.GF17268@fieldses.org>
References: <5176E715.2070201@gmx.de>
 <20130423215807.GL3676@fieldses.org>
 <51777494.8010306@gmx.de>
 <20130424140152.GA9794@fieldses.org>
 <5178116F.1010608@gmx.de>
 <20130424192353.GI20275@fieldses.org>
 <517A46E7.1020404@gmx.de>
 <20130426152334.GC17268@fieldses.org>
 <517AB1B3.7000301@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <517AB1B3.7000301@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 26, 2013 at 06:56:19PM +0200, Malte Schröder wrote:
> On 26.04.2013 17:23, J. Bruce Fields wrote:
> > On Fri, Apr 26, 2013 at 11:20:39AM +0200, Malte Schröder wrote:
> >> On 24.04.2013 21:23, J. Bruce Fields wrote:
> >>> On Wed, Apr 24, 2013 at 07:07:59PM +0200, Malte Schröder wrote:
> >>> Probably some of those "svc_process dropit"s are coming from attempts to
> >>> look up the newly created cred (so lookups in the rsc_cache) which fail
> >>> for some reason.  I'm not sure what that would be.
> >>>
> >>> --b.
> >>
> >> Hi,
> >> I tried bisecting the problem. It identified
> >> 683428fae8c73d7d7da0fa2e0b6beb4d8df4e808 as the problem, reverting it
> >> didn't fix the problem, though. During the process there where some
> >> states where mounting wouldn't hang but be denied. I will try bisecting
> >> again, later.
> > 
> > Oh, so probably 3c34ae11fac3b30629581d0bfaf80f58e82cfbfb "nfsd: fix krb5
> > handling of anonymous principals" needs backporting to stable--could you
> > confirm whether applying that helps?
> > 
> > Thanks for the bisection.
> > 
> > --b.
> > 
> 
> Well, I have the problem on 3.9-rc8, 3.8.5 works totally fine for me.

Oops, right--should have looked at the subject line.

> Just for fun I reverted the path you mentioned, and now the behaviour
> has changed: It doesn't hang anymore, now I get access denied from the
> server.

OK, I'm out of ideas for now....

--b.
