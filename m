From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching negative dentries
Date: Wed, 16 Jan 2008 15:49:20 -0500
Message-ID: <C8097339-F9C5-4350-823E-A99945F4600E@oracle.com>
References: <20080115163013.GC18911@newbie.thebellsplace.net> <1200415972.7702.7.camel@heimdal.trondhjem.org> <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com> <20080116012209.GB26010@newbie.thebellsplace.net> <1200451350.28088.43.camel@heimdal.trondhjem.org> <478DFD5A.1040501@RedHat.com> <01AE8AF878612047A442668306EAEB05018178E7@SACEXMV01.hq.netapp.com> <1200516219.6932.22.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Steve Dickson <SteveD@redhat.com>,
	Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:44447 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbYAPUva (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2008 15:51:30 -0500
In-Reply-To: <1200516219.6932.22.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 16, 2008, at 3:43 PM, Trond Myklebust wrote:
> On Wed, 2008-01-16 at 11:43 -0800, Muntz, Daniel wrote:
>> My $.02
>>
>>  -odircache=on
>>  -odircache=hitsonly (or positive, or hits, or ?)
>>  -odircache=off
>
>
> I like the 'dircache' bit, but to me 'on/off' suggests a binary  
> switch:
> they don't mix well with a third state.
>
> How about
>
>         -odircache=aggr[essive]	/* Full caching */
>         -odircache=noneg[ative]	/* Positive lookups only */
>         -odircache=off		/* strict lookup revalidation */

  "-olookupcache=" would be even more specific, if not more verbose.   
dircache=off implies that not even readdir results are cached.

	-olookupcache=full
	-olookupcache=pos[itive]
	-olookupcache=strict

>> -----Original Message-----
>> From: Steve Dickson [mailto:SteveD@redhat.com]
>> Sent: Wednesday, January 16, 2008 4:50 AM
>> To: Trond Myklebust
>> Cc: Bob Bell; Chuck Lever; NFS list
>> Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid
>> caching negative dentries
>>
>> Trond Myklebust wrote:
>>> On Tue, 2008-01-15 at 20:22 -0500, Bob Bell wrote:
>>>>>> How about something like 'cacheneglookup' 'nocacheneglookup'?
>>>>>> Better suggestions, anyone?
>>>> As long as no one objects to the length, I'll go with
>> "nocacheneglookup"
>>>> (and NFS_MOUNT_NOCACHENEGLOOKUP, I suppose) for round 2.
>>>
>>> I'm still not happy with that name. What do people think about
>>> introducing a generic 'cache' option that can be used for fine  
>>> control
>>
>>> of caching options?
>>>
>>> I'm thinking somewhat along the lines of
>>>
>>> 	-ocache=lookup_all		/* Cache all dentries */
>>> 	-ocache=lookup_positive		/* Cache positive dentries */
>>> 	-ocache=lookup_none		/* Force all lookups */
>> Maybe we should define the type of cache were are controlling, in  
>> case
>> we want to add controls for other caches. So how about:
>>
>>         -olpcache=all        /* Cache all directory entries */
>>         -olpcache=found      /* Cache only directory entires that are
>> found */
>>         -olpcache=off        /* Turn off the caching of directory
>> entries */
>>
>>
>> steved.
>> -
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org More majordomo  
>> info
>> at  http://vger.kernel.org/majordomo-info.html
>> -
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



