Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:50556 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581Ab0HZSzn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Aug 2010 14:55:43 -0400
Received: by pxi10 with SMTP id 10so748401pxi.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Aug 2010 11:55:43 -0700 (PDT)
Message-ID: <4C76B8AD.3000109@uw.edu>
Date: Thu, 26 Aug 2010 11:55:41 -0700
From: Harry Edmon <harry@uw.edu>
To: Christoph Hellwig <hch@infradead.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: Odd problem with Stale NFS file handle - NFS v3 server under
 2.6.35.x
References: <4C7407D2.1040304@uw.edu> <20100825105320.GA17190@infradead.org> <4C75948D.4040400@uw.edu> <20100826104541.GA23693@infradead.org>
In-Reply-To: <20100826104541.GA23693@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Christoph Hellwig wrote:
> On Wed, Aug 25, 2010 at 03:09:17PM -0700, Harry Edmon wrote:
>   
>> Christoph Hellwig wrote:
>>     
>>> Are you running xfs on this machine?  If so can you please try
>>> this patch:
>>>
>>> 	http://git.kernel.org/?p=linux/kernel/git/dgc/xfsdev.git;a=commitdiff;h=4536f2ad8b330453d7ebec0746c4374eadd649b1
>>>
>>>       
>> This looks very good so far.   I have been running it for 7 hours
>> with no problems.  That is much longer than I was able to run before
>> the patch.
>>
>> I notice that this patch (along with other xfs patches) has been
>> submitted for 2.6.36-rc3.   Do you plan to try to get this into
>> 2.6.35.5+ (2.6.35.4 is already in testing)?
>>     
>
> The commit was Cc'ed to the stable team, so it's expect that they will
> pick it up.
>
>   
The problem has not occurred since I installed this patch.   Call this 
problem solved.  Thanks again for all the help.

-- 
 Dr. Harry Edmon			E-MAIL: harry@uw.edu
 206-543-0547 FAX: 206-543-0308			harry@atmos.washington.edu
 Director of IT, College of the Environment and
 Director of Computing, Dept of Atmospheric Sciences
 University of Washington, Box 351640, Seattle, WA 98195-1640

