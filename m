From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 10/23] NFSD: move lockd_up() before svc_addsock()
Date: Mon, 9 Mar 2009 14:24:28 -0400
Message-ID: <87ACE9B1-F0D9-4423-BEE2-56112E14F056@oracle.com>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net> <20090305213238.21342.13075.stgit@ingres.1015granger.net> <565D1A54-1E66-46B0-B57A-E7108BC12E9D@oracle.com> <20090309181951.GC9408@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17758 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbZCISYo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2009 14:24:44 -0400
In-Reply-To: <20090309181951.GC9408@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 9, 2009, at Mar 9, 2009, 2:19 PM, J. Bruce Fields wrote:
> On Mon, Mar 09, 2009 at 02:15:11PM -0400, Chuck Lever wrote:
>>
>> On Mar 5, 2009, at Mar 5, 2009, 4:32 PM, Chuck Lever wrote:
>>
>>> Clean up.
>>>
>>> A couple of years ago, a series of commits, finishing with commit
>>> 5680c446, swapped the order of the lockd_up() and svc_addsock()  
>>> calls
>>> in __write_ports().  At that time lockd_up() needed to know the
>>> transport protocol of the passed-in socket to start a listener on  
>>> the
>>> same transport protocol.
>>>
>>> These days, lockd_up() doesn't take a protocol argument; it always
>>> starts both a UDP and TCP listener.  It's now more straightforward  
>>> to
>>> try the lockd_up() first, then do a lockd_down() if the  
>>> svc_addsock()
>>> fails.
>>>
>>> Careful review of this code shows that the svc_sock_names() call is
>>> used only to close the just-opened socket in case lockd_up() fails.
>>> So it is no longer needed if lockd_up() is done first.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> fs/nfsd/nfsctl.c |   19 ++++++++++---------
>>> 1 files changed, 10 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>> index 80f773b..aa60191 100644
>>> --- a/fs/nfsd/nfsctl.c
>>> +++ b/fs/nfsd/nfsctl.c
>>> @@ -908,17 +908,18 @@ static ssize_t __write_ports_addfd(char *buf)
>>> 	if (err != 0)
>>> 		return err;
>>>
>>> -	err = svc_addsock(nfsd_serv, fd, buf);
>>> -	if (err >= 0) {
>>> -		err = lockd_up();
>>> -		if (err < 0)
>>> -			svc_sock_names(buf + strlen(buf) + 1, nfsd_serv, buf);
>>> +	err = lockd_up();
>>> +	if (err != 0)
>>> +		goto out;
>>>
>>> -		/* Decrease the count, but don't shut down the service */
>>> -		nfsd_serv->sv_nrthreads--;
>>> -	}
>>> +	err = svc_addsock(nfsd_serv, fd, buf);
>>> +	if (err != 0)
>>
>> Found the "lockd: no users" BUG... this line needs to be "if (err <  
>> 0)".
>> Fix tested by Jeff Layton.
>
> OK, good.  Will you resend that one patch at some point?

There is a later patch that won't apply with this change, but the fix- 
up is trivial.  It might be easier if I just send the whole set again,  
but I would like to send them with the multiple-address-family- 
listeners patches that I posted for your review last week.  I haven't  
heard your thoughts on those.

> Are there any
> known problems left with that series?

None that I have found.

> --b.
>
>>
>>> +		lockd_down();
>>>
>>> -	return err < 0 ? err : 0;
>>> +out:
>>> +	/* Decrease the count, but don't shut down the service */
>>> +	nfsd_serv->sv_nrthreads--;
>>> +	return err;
>>> }
>>>
>>> /*
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




