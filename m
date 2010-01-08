From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/4] nfs-utils: add initial tests for statd that run via "make check"
Date: Fri, 8 Jan 2010 13:21:43 -0500
Message-ID: <CC60AF54-83DA-4E59-90D4-D29326A64920@oracle.com>
References: <1262962563-5554-1-git-send-email-jlayton@redhat.com> <1262962563-5554-5-git-send-email-jlayton@redhat.com> <70DEDD50-4AC5-4377-B5FA-A1FBCD92EBF3@oracle.com> <20100108115651.7a84a3c5@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: steved@redhat.com, bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:28551 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab0AHSWK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jan 2010 13:22:10 -0500
In-Reply-To: <20100108115651.7a84a3c5-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 8, 2010, at 11:56 AM, Jeff Layton wrote:

> On Fri, 8 Jan 2010 11:49:16 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>>
>> Basically what this tells me is that you can't runs these tests at  
>> all
>> if your development tree lives on an NFSv2/3 mount point.
>>
>
> I don't think the test I have so far will do any fcntl locking, so  
> that
> one would probably work. No guarantees on any that are added later  
> though.
>
> It's probably best to assume that doing so would be problematic.
>
>>> +	fi
>>> +	$srcdir/../utils/statd/statd --no-notify
>>
>> Is --no-notify really needed?  I guess that's just a safety net.
>>
>
> Yeah. On the off chance that someone has monitored hosts in the db
> after shutting down statd, I don't think we want to start spraying
> notifications when we start the test.

statd/sm-notify are supposed to be smart enough to send reboot  
notifications once per reboot anyway.  But it can't hurt to enforce it  
here.

>>> +}
>>> +
>>> +# shut down statd
>>> +kill_statd() {
>>> +	kill `cat /var/run/rpc.statd.pid`
>>> +}
>>> -- 
>>> 1.6.5.2
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
>
> -- 
> Jeff Layton <jlayton@redhat.com>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



