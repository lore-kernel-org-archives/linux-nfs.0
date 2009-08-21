From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 16:36:38 -0400
Message-ID: <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org> <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com> <20090821182418.GE21043@fieldses.org> <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com> <20090821200403.GA23529@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:60761 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932685AbZHUVLB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 17:11:01 -0400
In-Reply-To: <20090821200403.GA23529@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 21, 2009, at 4:04 PM, J. Bruce Fields wrote:
> On Fri, Aug 21, 2009 at 02:46:28PM -0400, Chuck Lever wrote:
>> On Aug 21, 2009, at 2:24 PM, J. Bruce Fields wrote:
>>> On Fri, Aug 21, 2009 at 02:16:08PM -0400, Chuck Lever wrote:
>>>> I want to understand the server bug a little more.  I glanced over
>>>> RFC
>>>> 2623 and didn't see anything specific.
>>>>
>>>> Is it the case that only Linux NFSD does this, or do other  
>>>> servers do
>>>> it?  In other words, is this a typical server response, and if  
>>>> so, is
>>>> there a specific semantic attached to it?
>>>>
>>>> If no list is provided, should the client assume that only  
>>>> AUTH_NONE
>>>> and
>>>> AUTH_SYS are supported, or instead, perhaps that the client can try
>>>> to
>>>> use any flavor?  In other words, if no list is provided, let the
>>>> mount
>>>> proceed no matter what was specified by sec= ?
>>>
>>> I think the safest behavior on the client would be something like:
>>>
>>> 	- If an explicit sec= is provided on the client, try that
>>> 	  flavor.  Otherwise:
>>> 		- If the server returned a nonempty list, pick something
>>> 		  off that list.  Otherwise:
>>> 		  	- Try auth_sys.
>>
>> Right now, we use AUTH_SYS if the mount command didn't specify a  
>> flavor,
>> but the flavor we're going to use is always checked against the  
>> server's
>> returned list.  You seem to be suggesting we should ignore the  
>> server's
>> list entirely if sec= was specified...?
>
> Yes.  I can't see what practical problems that would cause.

Well, it would mean our client isn't up to spec, confusing people who  
need to modify that code and people who expect a sec=krb5 mount to  
fail immediately if the server says it can't support AUTH_GSS_KRB5.

It may also not match the behavior of the legacy mount command on Linux.

> Also, while I hope this is the last bug in the mountd's flavor list
> return, it isn't the first--only recently did we even start using real
> information from the export instead of just faking something up.  So I
> think it's safest to preserve the historical sec= behavior and give
> users a way to override the negotiation, to cut down on bug reports of
> mount failures on upgrade.

OK, if this is a recently introduced server problem, then why do we  
need to adjust client-side behavior?  Trond's response in cases like  
this is usually "fix the d*mn server," which you've already done.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



