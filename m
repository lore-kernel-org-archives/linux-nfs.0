From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Re: nfsstat --sleep=#
Date: Wed, 11 Mar 2009 18:58:50 -0700
Message-ID: <49B86C5A.9000007@disney.com>
References: <49B86744.6060105@disney.com> <49B86C35.3030800@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:16004 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753652AbZCLB6w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 21:58:52 -0400
In-Reply-To: <49B86C35.3030800@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It seems like everyone has a patch or a script that does this sort of 
thing.  It'd be great if it was just a part of nfsstat the way that 
vmstat, and iostat print differences on a regular basis.

Greg Banks wrote:
> Kevin Constantine wrote:
>> I'd really like to have a way to output the nfsstat counters at
>> regular intervals (every 3 seconds) where the output is the difference
>> between 3 seconds ago and now.  Frequently I'll run a test and want to
>> watch the nfs call profile throughout the course of the test.
>>
>> Does something like this already exist?
>> Are there objections to seeing a feature like this?
> 
> I wrote some patches a couple of years back to do that.  I'll see if I
> can dig 'em up.
> 

-- 
------------------------------------------------------------
Kevin Constantine

Systems Engineer		t: 818.460.8221
Walt Disney Animation Studios	e: kevin.constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org

Any sufficiently advanced technology is indistinguishable from magic.
     - Arthur C. Clarke
