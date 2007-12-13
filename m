From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 09/38] svc: Add a transport function that checks for write space
Date: Thu, 13 Dec 2007 16:45:27 -0500
Message-ID: <1F79B182-2C72-46E0-A911-CE2722AF17FB@oracle.com>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233212.15718.69282.stgit@dell3.ogc.int> <421BFAC5-80AB-45E9-B67A-3770FDF353E9@oracle.com> <20071213213322.GE29496@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Tom Tucker <tom@opengridcomputing.com>, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:47631 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbXLMVp7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2007 16:45:59 -0500
In-Reply-To: <20071213213322.GE29496@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 13, 2007, at 4:33 PM, J. Bruce Fields wrote:
> On Wed, Dec 12, 2007 at 01:10:17PM -0500, Chuck Lever wrote:
>> On Dec 11, 2007, at 6:32 PM, Tom Tucker wrote:
>>> +	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
>>> +	wspace = sk_stream_wspace(svsk->sk_sk);
>>> +
>>> +	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
>>> +		return 0;
>>> +	if (required * 2 > wspace)
>>> +		return 0;
>>
>> Since "required" is an int, this test can behave differently than  
>> the one
>> it replaces.
>
> If sk_reserved can approach half of 2^31, for example, then surely we
> have bigger problems?


What stops sk_reserved from going negative?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
