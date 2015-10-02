Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54636 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbbJBJQq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2015 05:16:46 -0400
Subject: Re: [PATCH] lockd: create NSM handles per net namespace
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <1443012569-21623-1-git-send-email-aryabinin@virtuozzo.com>
 <20150929184745.GG3190@fieldses.org> <560D6103.9010306@virtuozzo.com>
 <20151001182630.GC10316@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <skinsbursky@virtuozzo.com>,
        <stable@vger.kernel.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <560E4B76.40504@virtuozzo.com>
Date: Fri, 2 Oct 2015 12:16:38 +0300
MIME-Version: 1.0
In-Reply-To: <20151001182630.GC10316@fieldses.org>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/01/2015 09:26 PM, J. Bruce Fields wrote:
> On Thu, Oct 01, 2015 at 07:36:19PM +0300, Andrey Ryabinin wrote:
>> On 09/29/2015 09:47 PM, J. Bruce Fields wrote:
>>> On Wed, Sep 23, 2015 at 03:49:29PM +0300, Andrey Ryabinin wrote:
>>>> Commit cb7323fffa85 ("lockd: create and use per-net NSM
>>>>  RPC clients on MON/UNMON requests") introduced per-net
>>>> NSM RPC clients. Unfortunately this doesn't make any sense
>>>> without per-net nsm_handle.
>>>
>>> Makes sense to me.  Is anyone doing testing to make sure we've got this
>>> right now?
>>>
>>> (For example, have you reproduced the below problem and verified that
>>> it's fixed after this patch?)
>>>
>>
>> Yes, that NULL-ptr was actually hit, so I've fixed it with this patch.
> 
> Great, thanks.  I'm queuing this up for 4.4 in the nfsd tree (assuming
> that's OK with Trond).
> 
> How extensively have you tested containerized nfs (client or server
> side) at this point? 

We have some tests for that, but we don't run them on upstream kernels,
only on OpenVZ.

> Have you seen any other issues?
> 

None, so far.
