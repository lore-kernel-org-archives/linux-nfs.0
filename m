Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linode.aoot.com ([69.164.194.13]:59247 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbcDZQpE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Apr 2016 12:45:04 -0400
Subject: Re: [PATCH v2 00/18] NFS/RDMA client patches for v4.7
To: Chuck Lever <chuck.lever@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <571F778B.5000306@opengridcomputing.com>
 <7580EA21-0782-470B-94FF-2B872A92B089@oracle.com>
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Wise <swise@opengridcomputing.com>
Message-ID: <571F9B0F.8050202@opengridcomputing.com>
Date: Tue, 26 Apr 2016 11:45:03 -0500
MIME-Version: 1.0
In-Reply-To: <7580EA21-0782-470B-94FF-2B872A92B089@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/26/2016 9:57 AM, Chuck Lever wrote:
>
>> On Apr 26, 2016, at 10:13 AM, Steve Wise <swise@opengridcomputing.com> wrote:
>>
>> Hey Chuck, I'm testing this series on cxgb4.    I'm running 'iozone -a -+d -I' on a share and watching the server stats.  Are the starve numbers expected?
>
> Yes, unless you're seeing much higher numbers than
> you used to.
>
>
>> Every 5.0s: for s in  /proc/sys/sunrpc/svc_rdma/rdma_* ; do echo -n "$(basename $s): "; cat $s; done                              Tue Apr 26 07:10:17 2016
>>
>> rdma_stat_read: 379872
>> rdma_stat_recv: 498144
>> rdma_stat_rq_poll: 0
>> rdma_stat_rq_prod: 0
>> rdma_stat_rq_starve: 675564
>
> This means work was enqueued on the svc_xprt, but by the
> time the upper layer invoked svc_rdma_recvfrom, the work
> was already handled by an earlier wake-up.
>
> I'm not exactly sure why this happens, but it seems to be
> normal (if suboptimal).
>
>
>> rdma_stat_sq_poll: 0
>> rdma_stat_sq_prod: 0
>> rdma_stat_sq_starve: 1748000
>
> No SQ space to post a Send, so the caller is put to sleep.
>
> The server chronically underestimates the SQ depth, especially
> for FRWR. I haven't figured out a better way to estimate it.
>
> But it's generally harmless, as there is a mechanism to put
> callers to sleep until there is space on the SQ.
>


Thanks.

With this iw_cxgb4 drain fix applied:

[PATCH 3/3] iw_cxgb4: handing draining an idle qp

http://www.spinics.net/lists/linux-rdma/msg34927.html

The series tests good over cxgb4.

Tested-by: Steve Wise <swise@opengridcomputing.com>

