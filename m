From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/2] showmount bug fixes
Date: Thu, 7 Jan 2010 17:43:20 -0500
Message-ID: <3C1CD7DD-E915-4FDB-815A-6D9B78A68AE5@oracle.com>
References: <20100107162421.27102.21422.stgit@localhost.localdomain> <4B461F48.4070906@RedHat.com> <7FEF347F-051D-4B08-A647-27506CFEC12A@oracle.com> <4B464355.1000405@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:60782 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab0AGWsu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2010 17:48:50 -0500
In-Reply-To: <4B464355.1000405-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 7, 2010, at 3:25 PM, Steve Dickson wrote:
> On 01/07/2010 01:38 PM, Chuck Lever wrote:
>> On Jan 7, 2010, at 12:52 PM, Steve Dickson wrote:
>>> On 01/07/2010 11:26 AM, Chuck Lever wrote:
>>>> Hi Steve-
>>>>
>>>> As promised, a couple of bug fixes for the recent improvements to  
>>>> the
>>>> showmount command.
>>>>
>>>> ---
>>>>
>>>> Chuck Lever (2):
>>>>     showmount: Use CLNT_CONTROL for version fallback
>>> Why is calling CLNT_CONTROL() verses calling clnt_create again
>>> so much better?? In between failures the server status could
>>> change so why not just ping it again??
>>>
>>
>> The clnt_create(3) library call is quite heavyweight.  It does a DNS
>> lookup via its own transport socket, a GETPORT via its own transport
>> socket, then creates and connects a socket to do the application's  
>> RPC
>> work.
>>
>> Each time showmount calls clnt_create(3), the library will set up a
>> socket for the DNS lookup (usually but not always UDP), set up a  
>> socket
>> to do a GETPORT, and then set up a third socket for the  
>> MNTPROC_EXPORT
>> request.  That's three sockets, each time through your retry loop.
>>
>> When contacting a MNTv1-only server over TCP, the showmount command  
>> can
>> leave up to six TCP sockets in TIME_WAIT (not counting sockets used  
>> for
>> DNS) for 120 seconds after the command exits, if it doesn't use
>> CLNT_CONTROL.
> Now really... who do you know that runs an v2 only server...
> I would call that badly misconfigured server... and I just
> don't think it happens...because if it did, the bug would have
> become much more prevalent a long time ago...

If you think v2-only servers are so rare, why even bother downshifting  
the protocol version at all?  The original showmount command does not  
have any problem connecting to a v2-only server, since it used only  
MNTv1 to do the EXPORT request.

Most legacy servers are NFSv2 only.  I bought a new-in-box ReadyNAS a  
year or so ago that ran Linux 2.4, and it's NFS server was, in fact,  
v2-only.

/me gives up.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



