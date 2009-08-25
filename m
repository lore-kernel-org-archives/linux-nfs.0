From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 11:36:00 -0400
Message-ID: <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com>
References: <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com> <20090821200403.GA23529@fieldses.org> <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com> <1250889345.5700.11.camel@heimdal.trondhjem.org> <20090821213016.GG23529@fieldses.org> <1250890836.5700.19.camel@heimdal.trondhjem.org> <20090821214720.GH23529@fieldses.org> <1250891463.5700.21.camel@heimdal.trondhjem.org> <20090824161004.GB4985@fieldses.org> <1251133618.6325.262.camel@heimdal.trondhjem.org> <20090824174129.GD4985@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:31451 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbZHYPgb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 11:36:31 -0400
In-Reply-To: <20090824174129.GD4985@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 24, 2009, at 1:41 PM, J. Bruce Fields wrote:
> On Mon, Aug 24, 2009 at 01:06:58PM -0400, Trond Myklebust wrote:
>> On Mon, 2009-08-24 at 12:10 -0400, J. Bruce Fields wrote:
>>> On Fri, Aug 21, 2009 at 05:51:02PM -0400, Trond Myklebust wrote:
>>>> On Fri, 2009-08-21 at 17:47 -0400, J. Bruce Fields wrote:
>>>>> On Fri, Aug 21, 2009 at 05:40:36PM -0400, Trond Myklebust wrote:
>>>>>> On Fri, 2009-08-21 at 17:30 -0400, J. Bruce Fields wrote:
>>>>>>> 	3c1bb23c037, first in 1.1.3, removes AUTH_NULL from that static
>>>>>>> 		list.
>>>>>>
>>>>>> Does the server support auth_null security? I didn't think it  
>>>>>> did.
>>>>>
>>>>> Just off the top of my head, without looking at the code: I  
>>>>> believe it
>>>>> treats auth_null rpc calls exactly as if they were auth_sys  
>>>>> calls with
>>>>> uid and gid set to the "anonymous" uid and gid.
>>>>
>>>> OK, so that would break too.
>>>
>>> I've lost track of the antecedent to "that".
>>
>> Negotiating AUTH_NULL security for those mountd programs that fake  
>> up a
>> list of flavours that excludes AUTH_NULL.
>
> OK, got it.
>
> (And note (a reminder to anyone that forgot) the omission of AUTH_NULL
> is a workaround for a bug in older mount.nfs which caused the client  
> to
> prefer flavors at the end of the list.  (Fixed in 3c1bb23c03, which  
> went
> into 1.1.3.  When was that bug introduced?)  That means some clients
> read the list forwards, and some backwards, so if you want clients to
> avoid picking AUTH_NULL by default, there's no safe place to put it.
> Since AUTH_NULL seems rarely needed, it seemed best just to leave it
> off.)

RFC 2623 suggests how the server should sort the returned flavor  
list.  However I don't think there's a consistent algorithm the client  
can use with that list to determine a good default for that mount.   
So, I would argue that any client that uses the "first" or "last"  
entry in that list as the mount's auth flavor is probably broken; it  
should pick a sec= default for all mounts, and if it's not on the  
returned list, fail the mount.  That is, incidentally, what the kernel  
MNT client does now.

> Anyway, we could add a second special case on the client side that
> allowed an explicit sec=null to bypass checking against the server  
> list.
> I don't know who actually needs mounts with sec=null.

Or, we can make sure the server provides AUTH_NULL in the list _only_  
if that flavor is specified explicitly on the export line.  Otherwise,  
a single entry flavor list (ie supporting only AUTH_UNIX) is probably  
the best default we can provide for the reasons you state above.

It would help to provide some documenting comments to that effect in  
the code, or maybe even state it in the exports(5) man page.

> And/or we could plan to put AUTH_NULL back on the server's list some
> day, depending on how widely disseminated we think the backwards mount
> behavior was....

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



