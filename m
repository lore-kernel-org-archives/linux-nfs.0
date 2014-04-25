Return-Path: linux-nfs-owner@vger.kernel.org
Received: from linode.aoot.com ([69.164.194.13]:51093 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbaDYNes (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 09:34:48 -0400
Message-ID: <535A6476.8080207@opengridcomputing.com>
Date: Fri, 25 Apr 2014 08:34:46 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org, tom@ogc.us
Subject: Re: [PATCH] svcrdma: refactor marshalling logic
References: <20140410183723.29724.18665.stgit@build.ogc.int> <20140425105838.GE22295@fieldses.org> <6B12FA09-0E8C-497A-9145-E2B7CAB16C53@oracle.com>
In-Reply-To: <6B12FA09-0E8C-497A-9145-E2B7CAB16C53@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/25/2014 8:24 AM, Chuck Lever wrote:
> Hi Bruce-
>
> On Apr 25, 2014, at 6:58 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
>> On Thu, Apr 10, 2014 at 01:37:23PM -0500, Steve Wise wrote:
>>> From: Tom Tucker <tom@ogc.us>
>>>
>>> This patch refactors the marshalling logic to remove the intermediary
>>> map structures.  It also fixes an existing bug where the NFSRDMA server
>>> was not minding the device fast register page list length limitations.
>>>
>>> Signed-off-by: Tom Tucker <tom@ogc.us>
>>> ---
>>>
>>> include/linux/sunrpc/svc_rdma.h          |    3
>>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  551 +++++++++---------------------
>>> net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  230 +------------
>>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   57 ++-
>>> 4 files changed, 222 insertions(+), 619 deletions(-)
>> Is it possible to make this change in more than one step?
>>
>> RDMA is pretty esoteric to most of us, so honestly this will probably
>> get merged based just on your having tested it, but if it was possible
>> to break this up into smaller patches you might give us at least a
>> fighting chance of giving it some review….
> I agree it could be broken up.
>
> However, my testing revealed that the patch inadvertently breaks support
> for HCAs that do not support FRMR.  I’ve reported this to Steve and Tom.
> IMO you should wait for a newer version of the refactoring patch.

I'll figure out the regression, and work with tom to repost this as a 
series.

Steve.

