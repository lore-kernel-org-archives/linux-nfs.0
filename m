From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [NFS] Forcefully resetting a lock
Date: Fri, 18 Apr 2008 09:02:06 -0500
Message-ID: <4808A9DE.9040304@gmail.com>
References: <200804161117.24734.hensema@hostingxs.nl>
	<48061807.9030808@gmail.com> <20080416184233.GF22743@fieldses.org>
	<480655E7.30800@gmail.com> <20080417215222.GK9912@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:59004 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbYDRODE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2008 10:03:04 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JmrB6-0005yI-Ek
	for linux-nfs@vger.kernel.org; Sat, 19 Apr 2008 00:03:00 +1000
In-Reply-To: <20080417215222.GK9912@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Apr 16, 2008 at 02:39:19PM -0500, Wendy Cheng wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Wed, Apr 16, 2008 at 10:15:19AM -0500, Wendy Cheng wrote:
>>>   
>>>       
>>>> Erik Hensema / HostingXS Internet Services wrote:
>>>>     
>>>>         
>>>>> Hi all,
>>>>>
>>>>> Sometimes a file lock gets stuck. Is there any way on either server 
>>>>> or  client to obtain a list of locks? Or a list of 
>>>>> processes/clients  locking a particular file?
>>>>> And the million dollar question: is it possible to forcefully 
>>>>> remove a  lock?
>>>>>
>>>>> I'm using NFSv4 on Linux 2.6.18 (server and client).
>>>>>
>>>>>         
>>>>>           
>>>> *Cough* !
>>>>
>>>> Bruce, so what happens to my lock dropping patch that was said "will 
>>>> get  pulled into 2.6.26 kernel" ?
>>>>     
>>>>         
>>> Gulp.
>>>
>>> I started an alternative implementation, and got it to the point where
>>> it was basically working (but I didn't completely trust it).  And I did
>>> a small fix or two on your patches, but I seem to recall there were one
>>> or more todo's there too.
>>>
>>> Then I dropped both for a couple weeks.
>>>   
>>>       
>> Be carefully. .. "a couple weeks" can turn into "a couple years" .. It  
>> has been more than 2 years since my first patch submission. Regardless  
>> the patch has been repeatedly requested and had gone thru thorough  
>> testings, it just sits there idling while Linux nfs server keeps  
>> suffering the very same issue.
>>     
>
> Yes, apologies for not getting this done on time.
>
>   
>> Don't get too ambitious. Cluster issues are not trivial - please take  
>> one step at a time. The patch is very usable *and* solves an immediate  
>> issue *and* has a clean boundary with existing main-line logic. I really  
>> don't see the reason to delay it.
>>     
>
> My current version of your patch follows.
>
> I've rebased it a couple times (the only change I recall being required
> was a trivial fix to take into account reorganization of struct
> nameidata.).  I also made two other changes; any objections to either?:
>   

Thanks for doing this... The changes look good - though I don't have 
chances to test it out yet. When is 2.6.26 code cut-off date (or we have 
missed it again) ?

-- Wendy
> 	



-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

