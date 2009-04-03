From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] nfsstat.c: Print diff stats every N seconds
Date: Fri, 03 Apr 2009 14:20:55 -0400
Message-ID: <49D65387.1020806@RedHat.com>
References: <1237225556-27691-1-git-send-email-kevin.constantine@disneyanimation.com> <49D62A92.5090907@RedHat.com> <49D642F7.3040900@disney.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53515 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753592AbZDCSXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Apr 2009 14:23:44 -0400
In-Reply-To: <49D642F7.3040900-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Kevin Constantine wrote:
> 
> Steve Dickson wrote:
>> Hey Kevin,
>>
>> I apologize for taking so long to look at this... but...
>>
>> Question: I notice that the v3 stats are displayed one
>> way (in list format) and the v4 stats are display in
>> another way (in column format) was this on purpose? Should they be
>> displayed using the same format?
> Steve-
> I re-worked, and re-submitted the patches per some suggestions from
> Greg.  I've since found an output bug that if --sleep=1 outputs a
> newline when there's no nfs traffic.  It'd probably just be easiest if I
> re-send the patches at this point if that works for you.
Yeah I did notice that newline bug as well... It seem to echo
newlines even when there was not data show... It was an easy 
enough to fix to I just when ahead and fixed it.. 

I'll wait for the repost.. will you be reposting the 
"nfsstat: Add --list flag" patch as well or is that
read to go?

steved.
