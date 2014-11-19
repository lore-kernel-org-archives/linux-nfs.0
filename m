Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:51908 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756379AbaKSQGK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 11:06:10 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so1170706wgh.9
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 08:06:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQZxYPo8=oxJP=+HOeO9NC7mMn9UkQUdEf6eL_0SwJW1Q@mail.gmail.com>
References: <1415833444-48129-1-git-send-email-trond.myklebust@primarydata.com>
	<20141112214128.4fc43a49@synchrony.poochiereds.net>
	<20141118201049.GH7419@fieldses.org>
	<9B8AE29D-A51D-4D04-965A-0B3C91DDB8A4@oracle.com>
	<CAHQdGtQZxYPo8=oxJP=+HOeO9NC7mMn9UkQUdEf6eL_0SwJW1Q@mail.gmail.com>
Date: Wed, 19 Nov 2014 08:06:09 -0800
Message-ID: <CAHQdGtSqeqRTcorHfiKNiAjVcnEMNmLNfU+ZzB4AtoEPpRtGFg@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix locking around callback channel reply receive
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 18, 2014 at 3:02 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Tue, Nov 18, 2014 at 12:14 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>> On Nov 18, 2014, at 3:10 PM, Bruce Fields <bfields@fieldses.org> wrote:
>>
>>> On Wed, Nov 12, 2014 at 09:41:28PM -0500, Jeff Layton wrote:
>>>> On Wed, 12 Nov 2014 18:04:04 -0500
>>>> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>>>
>>>>> Both xprt_lookup_rqst() and xprt_complete_rqst() require that you
>>>>> take the transport lock in order to avoid races with xprt_transmit().
>>>
>>> Thanks, looks right.
>>>
>>> Have you seen this in practice?  (I'm just wondering whether it's worth
>>> a stable cc:.)
>>
>> Since the backchannel has a single slot, I wonder if it
>> would be possible to race here.
>
> You would think not, but AFAICS the back channel code uses a soft
> mount with a timeout of lease_period/10. In case of a timeout, the
> slot is just released and the next request is queued.
>
> IOW: I believe that it is perfectly possible for the client to be a
> little late responding to the callback, and then to have the reply
> there race with the timeout.

BTW, Bruce, I also noticed a little race condition in
nfsd41_cb_get_slot(). The call to rpc_sleep_on() happens after the
test_and_set_bit(), with no locking so it is quite possible to race
with the clear_bit+ rpc_wake_up. If we want to do this in a lockless
fashion, then we would need to re-test_and_set_bit() in
nfsd41_cb_get_slot after the sleep...

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
