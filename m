Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4386 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019AbaGGUEz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2014 16:04:55 -0400
Message-ID: <53BAFD61.8030009@netapp.com>
Date: Mon, 7 Jul 2014 16:04:49 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: close potential race between delegation break and
 laundromat
References: <1404759818-10350-1-git-send-email-jlayton@primarydata.com> <20140707151450.7abd3db8@tlielax.poochiereds.net> <20140707193108.GF8630@fieldses.org>
In-Reply-To: <20140707193108.GF8630@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/07/2014 03:31 PM, J. Bruce Fields wrote:
> On Mon, Jul 07, 2014 at 03:14:50PM -0400, Jeff Layton wrote:
>> Sigh...after staring at this patch all day, I think I now see a
>> potential problem with the fault injection piece.
>>
>> In the "recall" case, we may find a delegation on the cl_delegations
>> list that has already been recalled. If that's the case, then we
>> probably should just skip it.
>>
>> I'll fix this patch, retest and resend. Sorry for the noise...
> 
> OK, so sounds like the fix isn't a big deal, but it also sounds like the
> fault injection code has come up as needing special attention a few
> times during this work now.
> 
> Has anyone actually ended up using that code?  Anna?

I used that code more often when I first wrote it, but I haven't played around with anything in at least a year.

Anna

> 
> In retrospect I wonder if it's worth the trouble.  It's very
> special-purpose stuff and if nobody's using it then maybe we could just
> remove it....
> 
> --b.
> 

