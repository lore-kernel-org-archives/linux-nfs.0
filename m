Return-Path: <SRS0=4uXo=PQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B950EC43387
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jan 2019 12:46:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 931CD20651
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jan 2019 12:46:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727295AbfAHMqp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 8 Jan 2019 07:46:45 -0500
Received: from mx1.redhat.com ([209.132.183.28]:41348 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727236AbfAHMqp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Jan 2019 07:46:45 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EE164C073D7D;
        Tue,  8 Jan 2019 12:46:43 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-64-2.rdu2.redhat.com [10.10.64.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 3869E5D9CC;
        Tue,  8 Jan 2019 12:46:42 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@hammerspace.com>
Cc:     anna.schumaker@netapp.com, dwysocha@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while
 handling TCP RST
Date:   Tue, 08 Jan 2019 07:46:42 -0500
Message-ID: <E4E398F0-1CCD-4692-95E7-25671A86664E@redhat.com>
In-Reply-To: <99a88b32d140228d5382eb176d0f19df27483654.camel@hammerspace.com>
References: <20181212135157.4489-1-dwysocha@redhat.com>
 <20181212135157.4489-2-dwysocha@redhat.com>
 <03049f893dfd265abb90fd2692bc41e1534f85d0.camel@hammerspace.com>
 <1544636846.3750.2.camel@redhat.com>
 <99a88b32d140228d5382eb176d0f19df27483654.camel@hammerspace.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 08 Jan 2019 12:46:44 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 12 Dec 2018, at 13:02, Trond Myklebust wrote:

> On Wed, 2018-12-12 at 12:47 -0500, Dave Wysochanski wrote:
>> On Wed, 2018-12-12 at 16:56 +0000, Trond Myklebust wrote:
>>> On Wed, 2018-12-12 at 08:51 -0500, Dave Wysochanski wrote:
>>>> Commit 9b30889c548a changed the handling of TCP_CLOSE inside
>>>> xs_tcp_state_change.  Prior to this change, the XPRT_CONNECTED
>>>> bit
>>>> was cleared unconditionally inside xprt_disconnect_done, similar
>>>> to the handling of TCP_CLOSE_WAIT.  After the change the clearing
>>>> of XPRT_CONNECTED depends on successfully queueing a work based
>>>> xprt_autoclose which depends on XPRT_LOCKED and may not happen.
>>>> This is significant in the case of an unexpected RST from the
>>>> server, as the client will only see xs_tcp_state_change called
>>>> with
>>>> sk_state == TCP_CLOSE.  Restore the unconditional clear_bit on
>>>> XPRT_CONNECTED while handling TCP_CLOSE and make it consistent
>>>> with handling TCP_CLOSE_WAIT.
>>>>
>>>> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
>>>> ---
>>>>  net/sunrpc/xprtsock.c | 1 +
>>>>  1 file changed, 1 insertion(+)
>>>>
>>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>>> index 8a5e823e0b33..b9789036051d 100644
>>>> --- a/net/sunrpc/xprtsock.c
>>>> +++ b/net/sunrpc/xprtsock.c
>>>> @@ -1492,6 +1492,7 @@ static void xs_tcp_state_change(struct sock
>>>> *sk)
>>>>  		if (sk->sk_err)
>>>>  			xprt_wake_pending_tasks(xprt, -sk-
>>>>> sk_err);
>>>>  		/* Trigger the socket release */
>>>> +		clear_bit(XPRT_CONNECTED, &xprt->state);
>>>>  		xs_tcp_force_close(xprt);
>>>>  	}
>>>>   out:
>>>
>>> Hi Dave,
>>>
>>> This isn't needed for 4.20 or newer because call_transmit() will
>>> now
>>> always call xprt_end_transmit(). I suggest that a stable fix do
>>> something similar (perhaps conditional on the error returned by
>>> xprt_transmit()?).
>>>
>>
>> Can you explain the handling in xs_tcp_state_change - why
>> XPRT_CONNECTED would need to remain set longer in the case of
>> handling
>> TCP_CLOSE case rather than TCP_CLOSE_WAIT?  It seems like if we get
>> an
>> RST we'll go directly to TCP_CLOSE and why would the XPRT_CONNECTED
>> bit
>> getting cleared need to be delayed in that case?
>>
>> I will look into the approach you mention though at the moment I do
>> not
>> see how it helps because the underlying issue seems to be clearing of
>> the XPRT_CONNECTED bit.
>>
>
> See xprt_clear_locked(). Dropping the XPRT_LOCK will automatically
> trigger autoclose if  XPRT_CLOSE_WAIT is set, regardless of whether or
> not there are other tasks waiting for the lock.

It seems to make sense to drop the XPRT_LOCK in call_transmit_status if
XPRT_CLOSE_WAIT is set.. something like:

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 336fd1a19cca..f30bf500888d 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -443,6 +443,11 @@ static inline int xprt_test_and_set_connecting(struct
rpc_xprt *xprt)
        return test_and_set_bit(XPRT_CONNECTING, &xprt->state);
 }

+static inline int xprt_close_wait(struct rpc_xprt *xprt)
+{
+       return test_bit(XPRT_CLOSE_WAIT, &xprt->state);
+}
+
 static inline void xprt_set_bound(struct rpc_xprt *xprt)
 {
        test_and_set_bit(XPRT_BOUND, &xprt->state);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8ea2f5fadd96..1fc812ba9871 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1992,13 +1992,15 @@ call_transmit(struct rpc_task *task)
 static void
 call_transmit_status(struct rpc_task *task)
 {
+       struct rpc_xprt *xprt = task->tk_rqstp->rq_xprt;
        task->tk_action = call_status;

        /*
         * Common case: success.  Force the compiler to put this
-        * test first.
+        * test first.  Or, if any error and xprt_close_wait,
+        * release the xprt lock so the socket can close.
         */
-       if (task->tk_status == 0) {
+       if (task->tk_status == 0 || xprt_close_wait(xprt)) {
                xprt_end_transmit(task);
                rpc_task_force_reencode(task);
                return;

Hmm.. I guess I have to figure out how to get a stable patch submitted that
will never have a mainline commit, since we don't have this problem in the
mainline.

Ben
