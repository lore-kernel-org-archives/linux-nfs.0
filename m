Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:50690 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759792AbaJ3Mmm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Oct 2014 08:42:42 -0400
Message-ID: <5452323F.5010703@Netapp.com>
Date: Thu, 30 Oct 2014 08:42:39 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Dave Chinner <david@fromorbit.com>
CC: <fstests@vger.kernel.org>, <hch@infradead.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] common:  Fixes for testing NFS over IPv6
References: <1414611127-14246-1-git-send-email-Anna.Schumaker@Netapp.com> <20141029233331.GO16186@dastard>
In-Reply-To: <20141029233331.GO16186@dastard>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/29/2014 07:33 PM, Dave Chinner wrote:
> On Wed, Oct 29, 2014 at 03:32:07PM -0400, Anna Schumaker wrote:
>> When testing NFS over IPv6, the user will set a $TEST_DEV of the form
>> [fe80::42]:/export.  The use of square brackets surrounding the IPv6
>> address is an accepted convention, but grep and awk think that our IPv6
>> address is actually a regex and tries to evaluate it instead.  The
>> result is that xfstests reports our filesystem "is busy or already
>> mounted".
>>
>> This patch fixes the IPv6 problem by telling awk and grep to treat
>> $TEST_DEV as a fixed string rather than a regex.
>>
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> Seems sensible, but it needs comments so that when someone copies
> the code they know why it's using these sorts of matches.

Sure.  I'll add that in, thanks!

> 
> Cheers,
> 
> Dave.
> 

