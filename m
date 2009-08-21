From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 16:04:41 -0400
Message-ID: <5CF4165E-2C0B-456E-A146-7A525DEE7B9F@oracle.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org> <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com> <20090821182418.GE21043@fieldses.org> <760BE185-BE57-42C2-817C-6776B5B66667@sun.com> <0BCE5960-E78A-4433-8D38-8DC2E6A0FDCF@oracle.com> <4A8EF847.8030500@sun.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Tom Haynes <Thomas.Haynes-xsfywfwIY+M@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:18790 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932821AbZHUVWm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 17:22:42 -0400
In-Reply-To: <4A8EF847.8030500-xsfywfwIY+M@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 21, 2009, at 3:40 PM, Tom Haynes wrote:
> Chuck Lever wrote:
>> On Aug 21, 2009, at 3:07 PM, Thomas Haynes wrote:
>>> Sent from my iPhone
>>>
>>> On Aug 21, 2009, at 1:24 PM, "J. Bruce Fields"  
>>> <bfields@fieldses.org> wrote:
>>>
>>>> On Fri, Aug 21, 2009 at 02:16:08PM -0400, Chuck Lever wrote:
>>>>> I want to understand the server bug a little more.  I glanced  
>>>>> over RFC
>>>>> 2623 and didn't see anything specific.
>>>>>
>>>>> Is it the case that only Linux NFSD does this, or do other  
>>>>> servers do
>>>>> it?  In other words, is this a typical server response, and if  
>>>>> so, is
>>>>> there a specific semantic attached to it?
>>>>>
>>>>> If no list is provided, should the client assume that only  
>>>>> AUTH_NONE and
>>>>> AUTH_SYS are supported, or instead, perhaps that the client can  
>>>>> try to
>>>>> use any flavor?  In other words, if no list is provided, let the  
>>>>> mount
>>>>> proceed no matter what was specified by sec= ?
>>>>
>>>> I think the safest behavior on the client would be something like:
>>>>
>>>>  - If an explicit sec= is provided on the client, try that
>>>>    flavor.  Otherwise:
>>>>      - If the server returned a nonempty list, pick something
>>>>        off that list.  Otherwise:
>>>>            - Try auth_sys.
>>>>
>>>
>>> Which is pretty much what we do. The exception being that the  
>>> default flavor is a setting - and probably always AUTH_SYS...
>>
>> I'm still not sure what is the right thing to do here.  Looking at  
>> 1813, it says:
>
> Sorry, I read this wrong, I thought the question was how should the  
> client handle
> security flavors from the mount command.
>
> With respect to the server returning a list, our implementation does  
> look at the list
> of returned flavors and only tries to use one in the list. That was  
> actually the fix that
> Bruce just applied - the linux server was returning an empty list  
> and the OpenSolaris
> server would fail the mount.

Thanks.

Do we know if other server implementations neglect to return a flavor  
list?  If it's only Linux, I guess it's reasonable for the client to  
assume the server supports AUTH_SYS in that case.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



