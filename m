From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 09/38] svc: Add a transport function that checks for write space
Date: Fri, 14 Dec 2007 08:59:36 -0500
Message-ID: <0DBD207F-4C55-421E-BA4E-CE6F1BD542A5@oracle.com>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233212.15718.69282.stgit@dell3.ogc.int> <421BFAC5-80AB-45E9-B67A-3770FDF353E9@oracle.com> <20071213213322.GE29496@fieldses.org> <1F79B182-2C72-46E0-A911-CE2722AF17FB@oracle.com> <1197584427.6348.10.camel@trinity.ogc.int> <20071213222837.GB11768@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Tom Tucker <tom@opengridcomputing.com>, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:52642 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbXLNOAf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Dec 2007 09:00:35 -0500
In-Reply-To: <20071213222837.GB11768@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 13, 2007, at 5:28 PM, J. Bruce Fields wrote:

> On Thu, Dec 13, 2007 at 04:20:27PM -0600, Tom Tucker wrote:
>>
>> On Thu, 2007-12-13 at 16:45 -0500, Chuck Lever wrote:
>>> On Dec 13, 2007, at 4:33 PM, J. Bruce Fields wrote:
>>>> On Wed, Dec 12, 2007 at 01:10:17PM -0500, Chuck Lever wrote:
>>>>> On Dec 11, 2007, at 6:32 PM, Tom Tucker wrote:
>>>>>> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
>>>>>> +	wspace = sk_stream_wspace(svsk->sk_sk);
>>>>>> +
>>>>>> +	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
>>>>>> +		return 0;
>>>>>> +	if (required * 2 > wspace)
>>>>>> +		return 0;
>>>>>
>>>>> Since "required" is an int, this test can behave differently than
>>>>> the one
>>>>> it replaces.
>>>>
>>>> If sk_reserved can approach half of 2^31, for example, then  
>>>> surely we
>>>> have bigger problems?
>>>
>>>
>>> What stops sk_reserved from going negative?
>>
>> Nothing actively _stops_ it from going negative. Indirectly it is
>> prevented by the "fact" that sv_max_mesg is always greater than the
>> amount returned by any read on the socket. If this is not true, then
>> sk_reserved can go negative. That would occur in svc_recv when the
>> difference between the amount currently reserved (worst case
>> sv_max_mesg) and the amount read is subtracted from the amount  
>> reserved.
>> If the amount read were greater than sv_max_mesg then the result  
>> would
>> be negative (both meanings intended).
>>
>> I could add a BUG_ON and run some tests.
>
> I have to admit, I'm completely and utterly lost here.  Chuck,  
> could you
> explain exactly, in detail, how you think this change could cause a  
> bug?


The original code has this:

static inline unsigned long
svc_sock_wspace(struct svc_sock *svsk)
{
	int wspace;

	if (svsk->sk_sock->type == SOCK_STREAM)
		wspace = sk_stream_wspace(svsk->sk_sk);
	else
		wspace = sock_wspace(svsk->sk_sk);

	return wspace;
}

   ...

	if (((atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg)*2
	     > svc_sock_wspace(svsk))

Since svc_sock_wspace() returns an unsigned long, that means the sum  
above is always converted to unsigned long.  If sk_reserved goes  
negative, then the sum becomes a large positive.

Note that in the TCP case, sk_stream_wspace() returns an int, which  
is also converted to an unsigned long by svc_sock_wspace().   
sk_stream_wspace() can return a negative if sk_wmem_queued happens to  
become larger than sk_sndbuf.

In all the other wspace callbacks I checked, the result of  
sk_stream_wspace() is compared to sk_stream_min_space() -- comparing  
an int to an int -- which means if sk_stream_wspace()'s result *does*  
go negative, those comparisons will catch it and do the right thing.

In the original RPC server implementation, though, sk_stream_wspace 
()'s result is converted to unsigned long; negative return values  
thus become large positives.

In both of these scenarios, the large positives make the comparison  
behave in exactly the opposite way we might expect it to.  Tom's code  
fixes this by making "required" an int for the TCP case so we still  
get an int-to-int comparison.

Because the original is coded the way it is, however, it's difficult  
to tell whether the signedness of these variables was intended for  
some clever effect, or whether it was an oversight.  If this was  
intentional, the new wspace check for TCP could have unintended  
performance consequences.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
