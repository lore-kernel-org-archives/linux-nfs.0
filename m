From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/2] showmount bug fixes
Date: Thu, 7 Jan 2010 13:38:03 -0500
Message-ID: <7FEF347F-051D-4B08-A647-27506CFEC12A@oracle.com>
References: <20100107162421.27102.21422.stgit@localhost.localdomain> <4B461F48.4070906@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:48141 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab0AGSrX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2010 13:47:23 -0500
In-Reply-To: <4B461F48.4070906-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 7, 2010, at 12:52 PM, Steve Dickson wrote:

>
>
> On 01/07/2010 11:26 AM, Chuck Lever wrote:
>> Hi Steve-
>>
>> As promised, a couple of bug fixes for the recent improvements to the
>> showmount command.
>>
>> ---
>>
>> Chuck Lever (2):
>>      showmount: Use CLNT_CONTROL for version fallback
> Why is calling CLNT_CONTROL() verses calling clnt_create again
> so much better?? In between failures the server status could
> change so why not just ping it again??
>

The clnt_create(3) library call is quite heavyweight.  It does a DNS  
lookup via its own transport socket, a GETPORT via its own transport  
socket, then creates and connects a socket to do the application's RPC  
work.

Each time showmount calls clnt_create(3), the library will set up a  
socket for the DNS lookup (usually but not always UDP), set up a  
socket to do a GETPORT, and then set up a third socket for the  
MNTPROC_EXPORT request.  That's three sockets, each time through your  
retry loop.

When contacting a MNTv1-only server over TCP, the showmount command  
can leave up to six TCP sockets in TIME_WAIT (not counting sockets  
used for DNS) for 120 seconds after the command exits, if it doesn't  
use CLNT_CONTROL.

In the TCP case, CLNT_CONTROL leaves the application's transport  
socket connected.  This means showmount doesn't perform any additional  
DNS or GETPORT requests (it does just one of each), and then one  
transport socket is used for all the MNTPROC_EXPORT request retries.   
Thus, with CLNT_CONTROL, showmount uses one TCP socket for a single  
GETPORT, and one socket to do the MNTPROC_EXPORT requests.

So in every case, showmount will use just two transport sockets (not  
counting the DNS query).  It's behavior is no different than your  
original patch if the server supports MNTv3, but much more efficient  
for the MNTv1-only case.

Leaving multiple sockets in TIME_WAIT is a regression from the  
original showmount behavior, hence this bug fix.  If a customer  
reported this problem, you wouldn't hesitate to apply this fix.  I'm  
not sure why you find this controversial.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



