Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbZH0ORr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Aug 2009 10:17:47 -0400
Message-ID: <4A969582.50702@RedHat.com>
Date: Thu, 27 Aug 2009 10:17:38 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Lans Carstensen <Lans.Carstensen@dreamworks.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/4] nfs-utils: nfs-iostat.py autofs cleanup and option
 to sort by ops/s
References: <4A94C133.8030904@dreamworks.com> <3644941A-3EA7-4755-867A-888E81A372FC@oracle.com> <4A9550FF.6010103@RedHat.com> <52E7928C-340C-45EF-9CFF-FB902332465F@oracle.com> <4A9578E4.4040402@RedHat.com> <78010D70-DEC9-4177-AFE8-CF1627ABD8A4@oracle.com> <4A95CBC7.5050001@dreamworks.com> <9AB6A612-3CAA-4215-8247-25B1F8111896@oracle.com>
In-Reply-To: <9AB6A612-3CAA-4215-8247-25B1F8111896@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/27/2009 10:04 AM, Chuck Lever wrote:
> On Aug 26, 2009, at 7:56 PM, Lans Carstensen wrote:
>> Chuck Lever wrote:
>>> On Aug 26, 2009, at 2:03 PM, Steve Dickson wrote:
>>>> On 08/26/2009 11:35 AM, Chuck Lever wrote:
>>>>> On Aug 26, 2009, at 11:13 AM, Steve Dickson wrote:
>>>>>> On 08/26/2009 10:28 AM, Chuck Lever wrote:
>>>>>>>
>>>>>>> On Aug 26, 2009, at 12:59 AM, Lans Carstensen wrote:
>>>>>>>
>>>>>>>> commit d3bb692a8c26c2d4e0dc70d7d0359daf79090e1e
>>>>>>>> Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
>>>>>>>> Date:   Tue Aug 25 21:52:03 2009 -0700
>>>>>>>>
>>>>>>>> Bump nfs-iostat.py version up to 0.3 to reflect new features.
>>>>>>>
>>>>>>> Now that nfs-iostat.py has been integrated into nfs-utils, I'm
>>>>>>> not sure
>>>>>>> we want to maintain an individual version number for it.  Maybe it
>>>>>>> should use the nfs-utils package's versioning instead... Steve, your
>>>>>>> thoughts?
>>>>>> Hmm... I don't think we tie any of other commands versions to
>>>>>> the package version....
>>>>>
>>>>> Actually many of the C commands do grab a macro defined during
>>>>> autoconfiguration: PACKAGE_VERSION.
>>>>>
>>>> Interesting.. I do see PACKAGE_VERSION being defined in
>>>> support/include/config.h
>>>> I guess I didn't know that was there and it does not seem to be used
>>>> by anybody... which is probably a problem but I don't think its a
>>>> problem
>>>> with this script...
>>> Right, I'm suggesting now would be a good time to switch these
>>> scripts over to the package-wide versioning scheme.
>>> But take a look at mount, statd, showmount, and nfsstat, at least: 
>>> these, for example, use the VERSION macro in their -V and usage
>>> messages.
>>
>> I agree with that concept but I'll kindly defer on the implementation
>> as I'm not exactly sure what would be required.
> 
> That's quite alright.  Probably Steve should cook something up for this
> one.
Yeah... don't get get hung up on this one... I'll deal with it...

steved.

