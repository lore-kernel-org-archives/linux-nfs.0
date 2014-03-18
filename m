Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:56914 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708AbaCRP6w convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Mar 2014 11:58:52 -0400
Received: by mail-ie0-f171.google.com with SMTP id ar20so7396872iec.2
        for <linux-nfs@vger.kernel.org>; Tue, 18 Mar 2014 08:58:52 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 1/2] SUNRPC: Ensure that call_connect times out correctly
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <53286A9D.2020007@RedHat.com>
Date: Tue, 18 Mar 2014 11:58:18 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <362845B0-35A4-4DDF-96F6-42582D66334B@primarydata.com>
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com> <53286A9D.2020007@RedHat.com>
To: Dickson Steve <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 18, 2014, at 11:47, Steve Dickson <SteveD@redhat.com> wrote:

> Hey,
> 
> On 03/17/2014 02:40 PM, Trond Myklebust wrote:
>> When the server is unavailable due to a networking error, etc, we want
>> the RPC client to respect the timeout delays when attempting to reconnect.
>> 
>> Fixes: 561ec1603171 (SUNRPC: call_connect_status should recheck bind..)
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> net/sunrpc/clnt.c | 8 +++-----
>> 1 file changed, 3 insertions(+), 5 deletions(-)
>> 
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 0edada973434..f22d3a115fda 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1798,10 +1798,6 @@ call_connect_status(struct rpc_task *task)
>> 	trace_rpc_connect_status(task, status);
>> 	task->tk_status = 0;
>> 	switch (status) {
>> -		/* if soft mounted, test if we've timed out */
>> -	case -ETIMEDOUT:
>> -		task->tk_action = call_timeout;
>> -		return;
>> 	case -ECONNREFUSED:
>> 	case -ECONNRESET:
>> 	case -ECONNABORTED:
>> @@ -1812,7 +1808,9 @@ call_connect_status(struct rpc_task *task)
>> 		if (RPC_IS_SOFTCONN(task))
>> 			break;
>> 	case -EAGAIN:
>> -		task->tk_action = call_bind;
>> +	case -ETIMEDOUT:
>> +		/* Check if we've timed out before looping back to call_bind */
>> +		task->tk_action = call_timeout;
>> 		return;
>> 	case 0:
>> 		clnt->cl_stats->netreconn++;
>> 
> How is this support to work if the trunking code still ignores timeouts? 
> 
> [ 2076.045176] NFS: nfs4_discover_server_trunking after status -110, retrying

The above patch fixes the regression that Neil tracked down in Linux 3.12, and that affects the generic RPC handling of soft timeouts.

The trunking code's handling of ETIMEDOUT has been there since Linux 3.7 and hasn’t changed, so I really don’t see how it can have worked at one time before 3.12.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

