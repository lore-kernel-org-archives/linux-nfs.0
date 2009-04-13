From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 3/3] nfsstat: Eliminate the displaying zero stats
Date: Mon, 13 Apr 2009 17:28:45 -0400
Message-ID: <49E3AE8D.70302@RedHat.com>
References: <49DCB9DA.5000300@RedHat.com> <49DCCB34.4080901@RedHat.com> <20090412172340.GD14592@fieldses.org> <49E32B4B.5060704@RedHat.com> <49E3701E.40202@disney.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48560 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753698AbZDMVbi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Apr 2009 17:31:38 -0400
In-Reply-To: <49E3701E.40202-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Kevin Constantine wrote:
> Steve Dickson wrote:
>> Hey Bruce,
>>
>> J. Bruce Fields wrote:
>>> On Wed, Apr 08, 2009 at 12:05:08PM -0400, Steve Dickson wrote:
>>>> Eliminate the displaying zero stats when the explicit protocol
>>>> is specified (-2, -3, -4) the -Z and or --list options.
>>>>     When a particular protocol is specified and either
>>>> the -Z or --list options are used, zeros or blank lines
>>>> are echoed to the screen when there is not any NFS traffic.
>>>> This cause any useful data to be scroll off the screen.
>>> Sound like good fixes.
>>>
>>>>     With this patch only non-zero stats will be shown, which
>>>> makes the output of these options more condensed and
>>>> in turn more useful.
>>> Couldn't this make the output harder to parse?  E.g. if you want to know
>>> how many getattr's were sent each second, it might be simpler if you say
>>> a 0 those times when there were no getattrs.
>>>
>> Maybe.. but if one was parsing the output and the parser didn't see a
>> gettr stat, I'm assuming it would not increment the "gettr counter"
>> so it would be know there were zero gettars in that time period..
>> The main reason I did this was, when watching reads and writes, 90% of
>> the output was zeros stats which made very difficult to see the non
>> zero counts (i.e. read and write stats) since they generally got
>> scrolled of the screen...
>> Also note, when the --list option is not used, zero stats are shown in
>> the column output, but granted, the column output
>> is a bit harder to parse than the list output.
>>
>> I guess I could change it so non zero stats are show only the --sleep
>> option is *not* used.... 
> 
> Dare I suggest another commandline argument?  I didn't really like the
> idea of leaving out the stats with 0's, but after trying it, the output
> does look a lot cleaner.  Perhaps giving users the choice would be the
> way to go.
hmm.. I'm not sure yet another flag would be good...

I guess I like the idea of having the output show what happen 
instead of what has not happen... also remember, the non list output
will show the zeros... But I'm open for compromise... 

steved.
 
