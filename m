Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823Ab0KJSDy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 13:03:54 -0500
Message-ID: <4CDADE85.6030806@RedHat.com>
Date: Wed, 10 Nov 2010 13:03:49 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: Harshula Jayasuriya <harshula@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: nfsstat: has_stats() does not function correctly
 for NFSv4 client stats
References: <1289328603.9490.18.camel@serendib> <33A5EC88-8770-4E5D-809A-28926ED3C5EC@oracle.com> <1289363200.9490.24.camel@serendib> <20101110162703.GA948@merit.edu>
In-Reply-To: <20101110162703.GA948@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 11/10/2010 11:27 AM, Jim Rees wrote:
> Harshula Jayasuriya wrote:
> 
>   On Tue, 2010-11-09 at 14:29 -0500, Chuck Lever wrote:
>   > Hi-
>   > 
>   > Why not use mountstats?  The /proc/net/rpc/nfs is destined for deprecation, I thought.
> 
>   Are you referring to /proc/self/mountstats? I didn't know about it.
>   nfsstat's get_stats() would have to be re-written. I can add that to my
>   TODO list, but not sure when I'll get to it. In the meantime, this patch
>   will fix the previously mentioned bugs and make the existing code a
>   little clearer.
> 
> We should either fix it or remove it.  Leaving it in and broken seems wrong
> even if the interface is depracated, especially since we have a fix.
Of course... I was not clear... I'll take the patch to fix the bug
but I don't think its worth whiled to teach nfsstat how read 
stats from /proc/self/mountstats... I would rather put the effort into
improving both the nfsiostat and mountstats command.

steved.
