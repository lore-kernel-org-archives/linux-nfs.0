Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:48764 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab0HYWJT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 18:09:19 -0400
Received: by pwi7 with SMTP id 7so468796pwi.19
        for <linux-nfs@vger.kernel.org>; Wed, 25 Aug 2010 15:09:19 -0700 (PDT)
Message-ID: <4C75948D.4040400@uw.edu>
Date: Wed, 25 Aug 2010 15:09:17 -0700
From: Harry Edmon <harry@uw.edu>
To: Christoph Hellwig <hch@infradead.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: Odd problem with Stale NFS file handle - NFS v3 server under
 2.6.35.x
References: <4C7407D2.1040304@uw.edu> <20100825105320.GA17190@infradead.org>
In-Reply-To: <20100825105320.GA17190@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Christoph Hellwig wrote:
> Are you running xfs on this machine?  If so can you please try
> this patch:
>
> 	http://git.kernel.org/?p=linux/kernel/git/dgc/xfsdev.git;a=commitdiff;h=4536f2ad8b330453d7ebec0746c4374eadd649b1
>
>   
This looks very good so far.   I have been running it for 7 hours with 
no problems.  That is much longer than I was able to run before the patch.

I notice that this patch (along with other xfs patches) has been 
submitted for 2.6.36-rc3.   Do you plan to try to get this into 
2.6.35.5+ (2.6.35.4 is already in testing)?

Thanks for the help, I really appreciate it!

-- 
 Dr. Harry Edmon			E-MAIL: harry@uw.edu
 206-543-0547 FAX: 206-543-0308			harry@atmos.washington.edu
 Director of IT, College of the Environment and
 Director of Computing, Dept of Atmospheric Sciences
 University of Washington, Box 351640, Seattle, WA 98195-1640

