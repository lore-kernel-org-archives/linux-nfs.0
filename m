Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:37121 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751232AbcFXVVl convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jun 2016 17:21:41 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Fields Bruce <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 05/10] SUNRPC: lock the socket while detaching it
Date: Fri, 24 Jun 2016 21:21:34 +0000
Message-ID: <470C748D-4E15-4F31-88B8-A78A446FDB1A@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
 <20160624210632.GJ3287@fieldses.org>
In-Reply-To: <20160624210632.GJ3287@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 24, 2016, at 17:06, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Fri, Jun 24, 2016 at 10:55:47AM -0400, Trond Myklebust wrote:
>> Prevent callbacks from triggering while we're detaching the socket.
> 
> What motivated this?  Do we have a bug without it?

Code inspection. Without locking, what ensures that you don’t have another processor calling into, say, svc_tcp_state_change() while this processor is tearing down your svc_sock.

> 
> --b.
> 
>> 
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> net/sunrpc/svcsock.c | 3 +++
>> 1 file changed, 3 insertions(+)
>> 
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index dadfec66dbd8..abe2da602fb8 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -1611,9 +1611,12 @@ static void svc_sock_detach(struct svc_xprt *xprt)
>> 	dprintk("svc: svc_sock_detach(%p)\n", svsk);
>> 
>> 	/* put back the old socket callbacks */
>> +	lock_sock(sk);
>> 	sk->sk_state_change = svsk->sk_ostate;
>> 	sk->sk_data_ready = svsk->sk_odata;
>> 	sk->sk_write_space = svsk->sk_owspace;
>> +	sk->sk_user_data = NULL;
>> +	release_sock(sk);
>> 
>> 	wq = sk_sleep(sk);
>> 	if (sunrpc_waitqueue_active(wq))
>> -- 
>> 2.7.4
> 

