From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 18:21:38 -0400
Message-ID: <09BF4444-844F-42DB-9BA9-0C1404A9D36B@oracle.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org> <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com> <20090821182418.GE21043@fieldses.org> <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com> <20090821200403.GA23529@fieldses.org> <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com> <1250889345.5700.11.camel@heimdal.trondhjem.org> <20090821213016.GG23529@fieldses.org> <1250890836.5700.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Tom Haynes <Thomas.Haynes-xsfywfwIY+M@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:62615 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932736AbZHUWwk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 18:52:40 -0400
In-Reply-To: <1250890836.5700.19.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 21, 2009, at 5:40 PM, Trond Myklebust wrote:
> On Fri, 2009-08-21 at 17:30 -0400, J. Bruce Fields wrote:
>> On Fri, Aug 21, 2009 at 05:15:45PM -0400, Trond Myklebust wrote:
>>> On Fri, 2009-08-21 at 16:36 -0400, Chuck Lever wrote:
>>>> On Aug 21, 2009, at 4:04 PM, J. Bruce Fields wrote:
>>>>> Also, while I hope this is the last bug in the mountd's flavor  
>>>>> list
>>>>> return, it isn't the first--only recently did we even start  
>>>>> using real
>>>>> information from the export instead of just faking something  
>>>>> up.  So I
>>>>> think it's safest to preserve the historical sec= behavior and  
>>>>> give
>>>>> users a way to override the negotiation, to cut down on bug  
>>>>> reports of
>>>>> mount failures on upgrade.
>>>>
>>>> OK, if this is a recently introduced server problem, then why do we
>>>> need to adjust client-side behavior?  Trond's response in cases  
>>>> like
>>>> this is usually "fix the d*mn server," which you've already done.
>>>
>>> What is the definition of "recently introduced" here? What is the  
>>> exact
>>> commit that introduced the bug in nfs-utils?
>>
>> By the way, looking at 'gitk utils/mountd/mountd.c' in my tree:
>>
>> 	Originally (didn't look to see how far it goes back), mountd
>> 		returned AUTH_NULL, AUTH_UNIX, in that order.
>> 	53c5bd65c74, first in 1.0.8, always returns
>> 		AUTH_NULL, AUTH_UNIX, AUTH_GSS_KRB5, AUTH_GSS_KRB5I,
>> 		AUTH_GSS_KRB5P, in that order.
>
> So all these should work without any trouble.
>
>> 	3c1bb23c037, first in 1.1.3, removes AUTH_NULL from that static
>> 		list.
>
> Does the server support auth_null security? I didn't think it did.
>
>> 	603017f2c15, first in 1.1.4, derives the psuedoflavor list from
>> 		the export (and introduces the above bug).
>
> That means the bug is likely to be in Fedora 10 and 11, the latest
> Debian and Ubuntu, as well as SLES 11. Sounds like a long list to  
> me...

Not an argument, but an observation: I think these are all currently  
maintained, and would thus be easy to fix.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



