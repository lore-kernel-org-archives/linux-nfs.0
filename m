Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:39815 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951Ab1KJQKE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 11:10:04 -0500
Message-ID: <4EBBF74C.2090107@panasas.com>
Date: Thu, 10 Nov 2011 08:09:48 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Benny Halevy <benny@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: Subject: [PATCH] SQUASHME: pnfsd: nfs4pnfsd.c should dprint under
 NFSDDBG_PNFS
References: <4EB9F8D6.1080302@panasas.com> <20111109195510.GA2227@fieldses.org> <4EBBF605.9050403@panasas.com>
In-Reply-To: <4EBBF605.9050403@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/10/2011 08:04 AM, Boaz Harrosh wrote:
> On 11/09/2011 11:55 AM, J. Bruce Fields wrote:
>> On Tue, Nov 08, 2011 at 07:51:50PM -0800, Boaz Harrosh wrote:
>>>
>>> I've been squinting  at pnfsd dprints for ages and aching under the wait. So I headed
>>> up to the nfsd/debug.h to add a PNFS channel, and what do you know? there is one!
>>> It's used by nfs4pnfsds.c. Surly  nfs4pnfsd.c is more _PNFS than _PROC.
>>
>> Hey now, nfs4pnfsd.c has enough problems of its own without being
>> accused of surliness.
>>
> 
> Allow me to disagree! the nfs4pnfsd.c is a very nice pretty clean, well formatted and
> well implemented pNFS-Server implementation. Believe me I have seen a few other pNFS
> and Parallel servers implementation and this is surgery room clean compare to the
> other. (If you look at the point before pnfs-exp and spNFS patches)
> 
> The only real mess in there is the mess already inherited from nfsd, like the great and grate
> messy locking. Though it's better then the rest of the NFSD code.
> 
> So you see, I do think it could be accused of "surliness"
> 

O, by the way I did not mean there is not lots of places for improvements and that the
code is perfect.

If you see things you don't like, or buggy or, could be done better, please tell us
so we can fix them.

>> --b.
>>
>>>
> 
> --Be
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

