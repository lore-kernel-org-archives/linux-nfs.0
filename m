From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH 3/3] nfsstat: Eliminate the displaying zero stats
Date: Mon, 13 Apr 2009 10:02:22 -0700
Message-ID: <49E3701E.40202@disney.com>
References: <49DCB9DA.5000300@RedHat.com> <49DCCB34.4080901@RedHat.com> <20090412172340.GD14592@fieldses.org> <49E32B4B.5060704@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:59960 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753804AbZDMRCZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 13:02:25 -0400
In-Reply-To: <49E32B4B.5060704-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:
> Hey Bruce,
> 
> J. Bruce Fields wrote:
>> On Wed, Apr 08, 2009 at 12:05:08PM -0400, Steve Dickson wrote:
>>> Eliminate the displaying zero stats when the explicit protocol
>>> is specified (-2, -3, -4) the -Z and or --list options.
>>>     
>>> When a particular protocol is specified and either
>>> the -Z or --list options are used, zeros or blank lines
>>> are echoed to the screen when there is not any NFS traffic.
>>> This cause any useful data to be scroll off the screen.
>> Sound like good fixes.
>>
>>>     
>>> With this patch only non-zero stats will be shown, which
>>> makes the output of these options more condensed and
>>> in turn more useful.
>> Couldn't this make the output harder to parse?  E.g. if you want to know
>> how many getattr's were sent each second, it might be simpler if you say
>> a 0 those times when there were no getattrs.
>>
> Maybe.. but if one was parsing the output and the parser didn't see a 
> gettr stat, I'm assuming it would not increment the "gettr counter"
> so it would be know there were zero gettars in that time period.. 
> 
> The main reason I did this was, when watching reads and writes, 90% of 
> the output was zeros stats which made very difficult to see the non 
> zero counts (i.e. read and write stats) since they generally got
> scrolled of the screen... 
> 
> Also note, when the --list option is not used, zero stats are 
> shown in the column output, but granted, the column output
> is a bit harder to parse than the list output.
> 
> I guess I could change it so non zero stats are show only 
> the --sleep option is *not* used....  
> 

Dare I suggest another commandline argument?  I didn't really like the 
idea of leaving out the stats with 0's, but after trying it, the output 
does look a lot cleaner.  Perhaps giving users the choice would be the 
way to go.

-kevin

> steved.
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
------------------------------------------------------------
Kevin Constantine

Systems Engineer		t: 818.460.8221
Walt Disney Animation Studios	e: kevin.constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org

Any sufficiently advanced technology is indistinguishable from magic.
     - Arthur C. Clarke
