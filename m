From: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 14:40:55 -0500
Message-ID: <4A8EF847.8030500@sun.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org>
 <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com>
 <20090821182418.GE21043@fieldses.org>
 <760BE185-BE57-42C2-817C-6776B5B66667@sun.com>
 <0BCE5960-E78A-4433-8D38-8DC2E6A0FDCF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brmea-mail-2.Sun.COM ([192.18.98.43]:39307 "EHLO
	brmea-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755011AbZHUTlI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 15:41:08 -0400
Received: from fe-amer-10.sun.com ([192.18.109.80])
	by brmea-mail-2.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n7LJf9DD005177
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2009 19:41:09 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KOQ00B00RD4T000-suYR2Hc8r9/lQFUxb2hVpgC/G2K4zDHf@public.gmane.org> for linux-nfs@vger.kernel.org; Fri,
 21 Aug 2009 13:41:09 -0600 (MDT)
In-reply-to: <0BCE5960-E78A-4433-8D38-8DC2E6A0FDCF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Aug 21, 2009, at 3:07 PM, Thomas Haynes wrote:
>> Sent from my iPhone
>>
>> On Aug 21, 2009, at 1:24 PM, "J. Bruce Fields" <bfields@fieldses.org> 
>> wrote:
>>
>>> On Fri, Aug 21, 2009 at 02:16:08PM -0400, Chuck Lever wrote:
>>>> I want to understand the server bug a little more.  I glanced over RFC
>>>> 2623 and didn't see anything specific.
>>>>
>>>> Is it the case that only Linux NFSD does this, or do other servers do
>>>> it?  In other words, is this a typical server response, and if so, is
>>>> there a specific semantic attached to it?
>>>>
>>>> If no list is provided, should the client assume that only 
>>>> AUTH_NONE and
>>>> AUTH_SYS are supported, or instead, perhaps that the client can try to
>>>> use any flavor?  In other words, if no list is provided, let the mount
>>>> proceed no matter what was specified by sec= ?
>>>
>>> I think the safest behavior on the client would be something like:
>>>
>>>   - If an explicit sec= is provided on the client, try that
>>>     flavor.  Otherwise:
>>>       - If the server returned a nonempty list, pick something
>>>         off that list.  Otherwise:
>>>             - Try auth_sys.
>>>
>>
>> Which is pretty much what we do. The exception being that the default 
>> flavor is a setting - and probably always AUTH_SYS...
>
> I'm still not sure what is the right thing to do here.  Looking at 
> 1813, it says:

Sorry, I read this wrong, I thought the question was how should the 
client handle
security flavors from the mount command.

With respect to the server returning a list, our implementation does 
look at the list
of returned flavors and only tries to use one in the list. That was 
actually the fix that
Bruce just applied - the linux server was returning an empty list and 
the OpenSolaris
server would fail the mount.


