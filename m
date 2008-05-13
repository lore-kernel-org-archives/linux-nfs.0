From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/20] svcrdma: RDMA transport driver close path cleanup.
Date: Tue, 13 May 2008 07:14:46 -0700
Message-ID: <4829A256.50708@panasas.com>
References: <12106196511042-git-send-email-tom@opengridcomputing.com>	 <20080513063342.GG1194@fieldses.org> <1210686283.16787.75.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:20683 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751167AbYEMOPX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 May 2008 10:15:23 -0400
In-Reply-To: <1210686283.16787.75.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 13, 2008, 6:44 -0700, Tom Tucker <tom@opengridcomputing.com> wrote:
> On Tue, 2008-05-13 at 02:33 -0400, J. Bruce Fields wrote:
>> On Mon, May 12, 2008 at 02:13:51PM -0500, Tom Tucker wrote:
>>> This is an updated version of the patchset that includes changes per 
>>> your recommendations, plus:
>>>
>>> - cleanup: changed the return type on svc_rdma_send_error to void
>>> - bug: added copy of transport address to the rqstp structure in rdma read
>>>   completion logic
>>> - bug: fixed svc_rdma_accept race that was found by inspection,
>> OK, thanks.  A minor whine: whatever procedure you're using to mail
>> these seems to alphabetize them like:
> 
> Ok, sorry about this. I was relying on the git send-email threading to
> get the order.

Unfortunately it doesn't do that if all patches are in reply to #0.
Threading helps more when they are all chained, but it's really ugly
and less useful especially with a large number of patches.

This script I use: git-send-patch, available here:
http://git.linux-nfs.org/?p=bhalevy/git-tools.git;a=blob_plain;f=git-send-patch;hb=master
Tries to keep the order by watching your mailq (in auto mode) and not sending
a patch before its predecessor was sent out.  This usually works, though
I think mail queues in between you and the list may still send stuff out of order...

Benny

> 
> I've modified my tool to format the subject like "%02/%02". This will
> get you 01/20, 02/20, etc... So they should sort alphabetically for
> subsequent submissions.
> 
> Tom
> 
>> 	11/20
>> 	1/20
>> 	12/20
>> 	13/20
>> 	14/20
>> 	15/20
>> 	16/20
>> 	17/20
>> 	18/20
>> 	19/20
>> 	20/20
>> 	2/20
>> 	3/20
>> 	...
>>
>> So the threading doesn't help apply them in the right order.
>>
>> Anyway, not a big problem.  And I'd also be just as happy to take them
>> from git if that'd be simpler.  (But from a quick glance I didn't see
>> a branch with the identical patches?)
>>
>> --b.
>>
>>> The original description follows:
>>>
>>> This patchset fixes a number of defects in the close path of the SVCRDMA
>>> transport provider. The defects were found by injecting errors on the 
>>> transport at random intervals while running concurrent iozone tests on
>>> IB and iWARP mounts. With this set of patches applied I was able to run
>>> the above tests for several hours without causing a crash or leaking
>>> resources. The transport recovers correctly on a client reconnect.
>>>
>>> This patchset is based on 2.6 top of tree, however, I think these fixes are
>>> good candidates for a 2.6.25 dot release as well. I have a set that is
>>> already merged for that release if you would like them. They are available in
>>> my git tree on linux-nfs.org in the '2.6.25' branch. Please let me know if you
>>> would like me to post them here.
>>>
>>> [PATCH 1/20] svcrdma: Simplify receive buffer posting
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   17 +----------------
>>>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   10 ++++++++++
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   19 -------------------
>>>  3 files changed, 11 insertions(+), 35 deletions(-)
>>>
>>> [PATCH 2/20] svcrdma: Fix race with dto_tasklet in svc_rdma_send
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   40 ++++++++++++++++-------------
>>>  1 files changed, 22 insertions(+), 18 deletions(-)
>>>
>>> [PATCH 3/20] svcrdma: Fix return value in svc_rdma_send
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> [PATCH 4/20] svcrdma: Add put of connection ESTABLISHED reference in rdma_cma_handler
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
>>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>>
>>> [PATCH 5/20] svcrdma: Free context on ib_post_recv error
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 ++
>>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>>
>>> [PATCH 6/20] svcrdma: Free context on post_recv error in send_reply
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_sendto.c |    3 ++-
>>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>>
>>> [PATCH 7/20] svcrdma: Fix error handling during listening endpoint creation
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   24 +++++++++++++-----------
>>>  1 files changed, 13 insertions(+), 11 deletions(-)
>>>
>>> [PATCH 8/20] svcrdma: Return error from rdma_read_xdr so caller knows to free context
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   23 ++++++++++++++++-------
>>>  1 files changed, 16 insertions(+), 7 deletions(-)
>>>
>>> [PATCH 9/20] svcrdma: Remove unused READ_DONE context flags bit
>>>
>>>  include/linux/sunrpc/svc_rdma.h          |    1 -
>>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 -
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 -
>>>  3 files changed, 0 insertions(+), 3 deletions(-)
>>>
>>> [PATCH 10/20] svcrdma: Simplify RDMA_READ deferral buffer management
>>>
>>>  include/linux/sunrpc/svc_rdma.h          |    1 +
>>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   58 ++++++------------------------
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 ++-
>>>  3 files changed, 16 insertions(+), 48 deletions(-)
>>>
>>> [PATCH 11/20] svcrdma: Use standard Linux lists for context cache
>>>
>>>  include/linux/sunrpc/svc_rdma.h          |    5 ++-
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   47 ++++++++++++++++-------------
>>>  2 files changed, 29 insertions(+), 23 deletions(-)
>>>
>>> [PATCH 12/20] svcrdma: Shrink scope of spinlock on RQ CQ
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ++--
>>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>>
>>> [PATCH 13/20] svcrdma: Move destroy to kernel thread
>>>
>>>  include/linux/sunrpc/svc_rdma.h          |    1 +
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   17 ++++++++++++++---
>>>  2 files changed, 15 insertions(+), 3 deletions(-)
>>>
>>> [PATCH 14/20] svcrdma: Add reference for each SQ/RQ WR
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   18 ++++++++++++++++--
>>>  1 files changed, 16 insertions(+), 2 deletions(-)
>>>
>>> [PATCH 15/20] svcrdma: Move the QP and cm_id destruction to svc_rdma_free
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   40 +++++++++++++++---------------
>>>  1 files changed, 20 insertions(+), 20 deletions(-)
>>>
>>> [PATCH 16/20] svcrdma: Cleanup queued, but unprocessed I/O in svc_rdma_free
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   38 +++++++++++++++++++++++++++--
>>>  1 files changed, 35 insertions(+), 3 deletions(-)
>>>
>>> [PATCH 17/20] svcrdma: Use ib verbs version of dma_unmap
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    8 ++++----
>>>  1 files changed, 4 insertions(+), 4 deletions(-)
>>>
>>> [PATCH 18/20] svcrdma: Set rqstp transport address in rdma_read_complete function
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    1 +
>>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>>
>>> [PATCH 19/20] svcrdma: Copy transport address and arm CQ before calling rdma_accept
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   23 ++++++++++++++---------
>>>  1 files changed, 14 insertions(+), 9 deletions(-)
>>>
>>> [PATCH 20/20] svcrdma: Change svc_rdma_send_error return type to void
>>>
>>>  include/linux/sunrpc/svc_rdma.h          |    4 ++--
>>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    2 +-
>>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    9 ++++-----
>>>  3 files changed, 7 insertions(+), 8 deletions(-)
>>>
>>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>> .
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

