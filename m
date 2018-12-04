Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87D57C04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 20:04:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 39FF12082B
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 20:04:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="eV+fdCb2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39FF12082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725859AbeLDUE1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 15:04:27 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:37862 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725797AbeLDUE1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 15:04:27 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wB4K4P6d031612;
        Tue, 4 Dec 2018 20:04:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=dUhTiwel4ouEEntW5/Z5xbUS1dEj/bRk3RPgmANcfyQ=;
 b=eV+fdCb2rg7ULPwL0k9B+en7Y6ZYNmyuVI0UcNCHPT2+gJ/RpawMQvfoJJ8tJR4Pzxwy
 tAxRcXw7JUL6RGCOqXe1ANCLmnOANmmU6zyAk3d5DtyyMS80CGFJu/QXaNSar8DUGCUA
 So2RdZTL5nMMM8YK5h8VMMPUoDVfsSf88WAnW9wZsQEih+hpp6kziy8QdSvPTHIWwprH
 SqY53l0tESngvPs2VVuvLVOcYx6ZX3nKocUS+VtYj02Ma8dLZr5nwPkQxpD52a+SxdrZ
 FziAIrBYuIwmVyXtPv3QvYLqeMP2KePy7aZfZZ/CYDNpp6uuvWoGcDqgdeGNGVf44u2y qA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2p3jxrejcb-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 04 Dec 2018 20:04:25 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wB4K4OEG008562
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 4 Dec 2018 20:04:24 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wB4K4OdK003075;
        Tue, 4 Dec 2018 20:04:24 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 04 Dec 2018 12:04:24 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] SUNRPC: Fix a potential race in xprt_connect()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <fdb18aece66221c91c0f8ce4e0a7849bc60505fc.camel@hammerspace.com>
Date:   Tue, 4 Dec 2018 15:04:22 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <F97D7A8E-D9F9-4F72-B943-1FD75907EE65@oracle.com>
References: <20181202144223.42562-1-trond.myklebust@hammerspace.com>
 <4BAC007E-35BE-423B-BA11-5413D0EEDDBD@oracle.com>
 <fdb18aece66221c91c0f8ce4e0a7849bc60505fc.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9097 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812040172
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 2, 2018, at 12:26 PM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
> On Sun, 2018-12-02 at 12:07 -0500, Chuck Lever wrote:
>> Test report.
>> 
>> I applied this on top of the three v4 patches from Friday.
>> 
>> With TCP, I no longer see the soft IRQ warnings or bdev leaks.
>> However, at some point during my test (sec=krb5p,vers=3) the
>> mount stops responding and the client becomes idle. ^C leaves
>> the iozone processes in D state.
> 
> Does /proc/*/stack show any tasks with any interesting stack behaviour?
> 
>> 
>> With RDMA, I can see a few issues:
>> - A lot of -74 and server disconnects. I suspect this is due
>>   to GSS sequence window overruns
>> - xprt_connect puts the calling task to sleep if the credit
>>   limit has been reached, and that can result in a deadlock
>> - The reconnect logic appears to busy-wait until something
>>   else (eg, an RTO) forces a reconnect
>> - A connect or disconnect wake-up that occurs while an RPC
>>   reply is being handled (ie, is still on xprt->pending)
>>   results in that RPC being retried unnecessarily.
>> 
>> I'm not sure how to address that last one. Sometimes RDMA has
>> to invalidate MRs, and that involves a wait/context swith which
>> opens the race window significantly.
> 
> In principle the latter issue is supposed to be handled by the connect
> cookies. Are the updates perhaps being ordered incorrectly w.r.t. the
> xprt->pending wakeup? If so, then that could cause races.
> 
> I'd expect the cookie would need to be updated before the call to xprt-
> pending both on connect and disconnect.

xprtrdma does this in rpcrdma_cm_event_handler.

I'm at a loss to understand how connect cookies can help. During a
disconnect, rpc_wake_pending_tasks sets tk_status to -EAGAIN, but a
subsequent xprt_complete_rqst does not set tk_status. When
xprt_complete_rqst wakes up the waiting RPC task, that task sees
-EAGAIN rather than a successful RPC completion.


>>> On Dec 2, 2018, at 9:42 AM, Trond Myklebust <trondmy@gmail.com>
>>> wrote:
>>> 
>>> If an asynchronous connection attempt completes while another task
>>> is
>>> in xprt_connect(), then the call to rpc_sleep_on() could end up
>>> racing with the call to xprt_wake_pending_tasks().
>>> So add a second test of the connection state after we've put the
>>> task to sleep and set the XPRT_CONNECTING flag, when we know that
>>> there
>>> can be no asynchronous connection attempts still in progress.
>>> 
>>> Fixes: 0b9e79431377d ("SUNRPC: Move the test for XPRT_CONNECTING
>>> into...")
>>> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
>>> ---
>>> net/sunrpc/xprt.c | 11 +++++++++--
>>> 1 file changed, 9 insertions(+), 2 deletions(-)
>>> 
>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>> index 122c91c28e7c..ce927002862a 100644
>>> --- a/net/sunrpc/xprt.c
>>> +++ b/net/sunrpc/xprt.c
>>> @@ -826,8 +826,15 @@ void xprt_connect(struct rpc_task *task)
>>> 			return;
>>> 		if (xprt_test_and_set_connecting(xprt))
>>> 			return;
>>> -		xprt->stat.connect_start = jiffies;
>>> -		xprt->ops->connect(xprt, task);
>>> +		/* Race breaker */
>>> +		if (!xprt_connected(xprt)) {
>>> +			xprt->stat.connect_start = jiffies;
>>> +			xprt->ops->connect(xprt, task);
>>> +		} else {
>>> +			xprt_clear_connecting(xprt);
>>> +			task->tk_status = 0;
>>> +			rpc_wake_up_queued_task(&xprt->pending, task);
>>> +		}
>>> 	}
>>> 	xprt_release_write(xprt, task);
>>> }
>>> -- 
>>> 2.19.2
>>> 
>> 
>> --
>> Chuck Lever
>> 
>> 
>> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

--
Chuck Lever



