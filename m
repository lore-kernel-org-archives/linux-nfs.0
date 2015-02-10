Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f172.google.com ([209.85.220.172]:36766 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbbBJQKN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Feb 2015 11:10:13 -0500
Received: by mail-vc0-f172.google.com with SMTP id kv7so1346313vcb.3
        for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2015 08:10:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54DA29AA.7060702@Netapp.com>
References: <1423522091-35365-1-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-2-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-3-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-4-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-5-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-6-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-7-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-8-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-9-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-10-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-11-git-send-email-trond.myklebust@primarydata.com>
	<1423522091-35365-12-git-send-email-trond.myklebust@primarydata.com>
	<54DA29AA.7060702@Netapp.com>
Date: Tue, 10 Feb 2015 11:10:12 -0500
Message-ID: <CAHQdGtRuZHAjqEJOQhti0dE4+SFt4gAXPTei=oyHEcXJmyr68A@mail.gmail.com>
Subject: Re: [PATCH v3 11/15] SUNRPC: Make xs_tcp_close() do a socket shutdown
 rather than a sock_release
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 10, 2015 at 10:54 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Hi Trond,
>
> On 02/09/2015 05:48 PM, Trond Myklebust wrote:
>> Use of socket shutdown() means that we monitor the shutdown process
>> through the xs_tcp_state_change() callback, so it is preferable to
>> a full close in all cases unless we're destroying the transport.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  net/sunrpc/xprtsock.c | 6 +-----
>>  1 file changed, 1 insertion(+), 5 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 3d83cbd32ef2..0279e8ffb14a 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -857,10 +857,7 @@ static void xs_close(struct rpc_xprt *xprt)
>>
>>  static void xs_tcp_close(struct rpc_xprt *xprt)
>>  {
>> -     if (test_and_clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state))
>> -             xs_close(xprt);
>> -     else
>> -             xs_tcp_shutdown(xprt);
>> +     xs_tcp_shutdown(xprt);
>
> Can we remove xs_tcp_close() and call tcp_shutdown() directly instead?

Ack. I've added a patch for that.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
