Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:60324 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936Ab1HCH2c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 03:28:32 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p737MBSA010289
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 01:22:11 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p737SSVN199376
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 01:28:28 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p737SRfY021045
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 01:28:27 -0600
Message-ID: <4E38F894.4070003@linux.vnet.ibm.com>
Date: Wed, 03 Aug 2011 00:28:20 -0700
From: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com
Subject: Re: State of NFSv4 VolatileFilehandles
References: <4E37E66D.90102@linux.vnet.ibm.com> <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
In-Reply-To: <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/02/2011 07:53 AM, Chuck Lever wrote:
> On Aug 2, 2011, at 7:58 AM, Venkateswararao Jujjuri wrote:
>
>> We at IBM receiving multiple customer requests for supporting NFSv4 server migration.
>> I have referred to Trond and Chuck's presentations at 2011 Connectathon and there appears to be
>> sizable work remaining. I am not sure if there is any progress made since those talks.
>>
>> I would like to open up a discussion thread on the mailing list to understand the latest status.
>> Also would like to get the input on the Volatile Filehandles (VFH). I searched the mailing list, and could not
>> find any recent discussion on this.
>>
>> Some discussion points:
>> - What are the pieces left to attain full client/server support for seamless server migration?
> The client migration implementation is code complete and in test now.  This includes both minor version 0 and 1.  We don't have any mv1 servers to test with at this time, so that support is provisional.  I hope to have patches ready for the 3.2 merge window, but you can see what I've got now on git.linux-nfs.org.
Great I will take it from there. Is it your branch or Trand's ? Can you 
please give me which project/branch
I should take from git.linux-nfs.org?
>
> A problem is that there are corner cases in the v4.0 migration specification that are still unresolved.  We are working with the NFSv4 WG to get these addressed.  But I expect some minor changes even after the patches are merged upstream.
What are those corner cases? Is it on any mailing list? Is it possible 
for us to see that discussion?
>
> We don't have firm plans for a server migration implementation on Linux at this time, but Bruce can maybe say more about that.
Sure; would wait for Bruce's views on this. We are getting requirements 
for both client and server support.

>> - Any discussion/sugestions on the way to implement VFH?  As described in RFC 3530 sections 4.2.3 and 4.2.4?
> I think we are avoiding volatile file handles as long as possible.  We don't have plans to implement them at the moment.
Hrm. How can we achieve the complete migration support without volatile 
filehandle support?
What are the reasons for avoiding it? May be we can start looking into 
this but would like to understand
the reasons (if any) for avoiding it.

Thanks a lot for your quick response.

- JV

>> - Are there any community efforts going / about to start in this area? so that we can partner and get
>>   things done instead of duplicating the work.
>>
>> Thanks a lot for your help
>> JV

