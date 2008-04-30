From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: lock reclaims outside grace period
Date: Tue, 29 Apr 2008 19:45:07 -0500
Message-ID: <4817C113.2000603@gmail.com>
References: <20080429215707.GF26468@fieldses.org> <1209507531.8321.11.camel@heimdal.trondhjem.org> <20080430000349.GA32692@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.228]:45861 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbYD3ApO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2008 20:45:14 -0400
Received: by qb-out-0506.google.com with SMTP id e11so243369qbe.15
        for <linux-nfs@vger.kernel.org>; Tue, 29 Apr 2008 17:45:12 -0700 (PDT)
In-Reply-To: <20080430000349.GA32692@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Tue, Apr 29, 2008 at 03:18:51PM -0700, Trond Myklebust wrote:
>   
>> On Tue, 2008-04-29 at 17:57 -0400, J. Bruce Fields wrote:
>>     
>>> Current lockd code appears to reject regular locks done during the grace
>>> period, but not reclaims that come outside of the grace period.
>>>
>>> (That's based on inspecting the code--I haven't run tests.)
>>>
>>> That seems like an obvious bug.  (We're not giving the client any way to
>>> determine whether conflicting locks might have been granted.)
>>>
>>> Can we fix it, or is there a chance that people have been depending on
>>> this behavior?  (Maybe for failing over to an already-active server??)
>>>       
>> Sorry, but I really don't care if anyone has been relying on it: that is
>> a _major_ bug and needs to be fixed ASAP.
>>     
>
> OK, good, I'll do some tests to confirm and then submit a patch.
>   

I can't disagree - but do prepare people start to ask why after kernel 
version 2.6.x, they have to extend grace period to get NFS locking works 
:) ...

-- Wendy

