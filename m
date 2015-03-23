Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34537 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbbCWBQa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Mar 2015 21:16:30 -0400
Received: by pacwe9 with SMTP id we9so174480035pac.1
        for <linux-nfs@vger.kernel.org>; Sun, 22 Mar 2015 18:16:30 -0700 (PDT)
Message-ID: <550F6964.4030005@gmail.com>
Date: Mon, 23 Mar 2015 09:16:20 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4: Retry destroy session when getting -NFS4ERR_DELAY
References: <550BDAE0.2070409@gmail.com> <CAHQdGtSJ8GtC5DL2wh5BjyBBEEV_53pjvX-_CD4vCGkzHWY=2g@mail.gmail.com>
In-Reply-To: <CAHQdGtSJ8GtC5DL2wh5BjyBBEEV_53pjvX-_CD4vCGkzHWY=2g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2015/3/23 3:14, Trond Myklebust wrote:
> On Fri, Mar 20, 2015 at 4:31 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>> When umounting a client, it cost near ten seconds.
>> Dump the request, got
>>    client                     server
>> DELEGRETURN              ---->
>> DESTROY_SESSION          ---->
>>           NFS4ERR_DELAY  <----  DESTROY_SESSION reply
>>                 NFS4_OK  <----  DELEGRETURN reply
>> DESTROY_CLIENTID          ---->
>>   NFS4ERR_CLIENTID_BUSY  <----  DESTROY_CLIENTID reply
>> DESTROY_CLIENTID          ---->
>>   NFS4ERR_CLIENTID_BUSY  <----  DESTROY_CLIENTID reply
>>          ... ....                  ... ...
>> There are ten DESTROY_CLIENTID requests.
>> This patch retry DESTROY_SESSION when getting NFS4ERR_DELAY,
>> try the best to destroy the session as destroy clientid.
>>
>> With this patch, only cost more than 1 seconds, as,
>>    client                     server
>> DELEGRETURN          ---->
>> DESTROY_SESSION      ---->
>>      NFS4ERR_DELAY  <----  DESTROY_SESSION reply
>>            NFS4_OK  <----  DELEGRETURN reply
>> DESTROY_SESSION      ---->
>>            NFS4_OK  <----  DESTROY_SESSION reply
>> DESTROY_CLIENTID     ---->
>>            NFS4_OK  <----  DESTROY_CLIENTID reply
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfs/nfs4proc.c | 26 +++++++++++++++++++++-----
>>  1 file changed, 21 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 627f37c..2631dc2 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -7320,7 +7320,7 @@ out:
>>   * Issue the over-the-wire RPC DESTROY_SESSION.
>>   * The caller must serialize access to this routine.
>>   */
>> -int nfs4_proc_destroy_session(struct nfs4_session *session,
>> +static int _nfs4_proc_destroy_session(struct nfs4_session *session,
>>                 struct rpc_cred *cred)
>>  {
>>         struct rpc_message msg = {
>> @@ -7332,10 +7332,6 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
>>
>>         dprintk("--> nfs4_proc_destroy_session\n");
>>
>> -       /* session is still being setup */
>> -       if (!test_and_clear_bit(NFS4_SESSION_ESTABLISHED, &session->session_state))
>> -               return 0;
>> -
>>         status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
>>         trace_nfs4_destroy_session(session->clp, status);
>>
>> @@ -7347,6 +7343,26 @@ int nfs4_proc_destroy_session(struct nfs4_session *session,
>>         return status;
>>  }
>>
>> +int nfs4_proc_destroy_session(struct nfs4_session *session,
>> +               struct rpc_cred *cred)
>> +{
>> +       unsigned int loop;
>> +       int ret;
>> +
>> +       /* session is still being setup */
>> +       if (!test_and_clear_bit(NFS4_SESSION_ESTABLISHED, &session->session_state))
>> +               return 0;
>> +
>> +       for (loop = NFS4_MAX_LOOP_ON_RECOVER; loop != 0; loop--) {
>> +               ret = _nfs4_proc_destroy_session(session, cred);
>> +               if (ret != -NFS4ERR_DELAY)
>> +                       break;
>> +               ssleep(1);
>> +       }
>> +
>> +       return ret;
>> +}
>> +
>>  /*
>>   * Renew the cl_session lease.
>>   */
>> --
>> 2.3.3
>>
> 
> I don't understand. All you've done is paper over the problem AFAICS.
> How is that useful?

Sorry for missing more comments.
When unmounting nfs with delegation, client will return delegation first,
then call nfs41_shutdown_client() destory session and clientid.

DELEGRETURN using asynchronous RPC，destroy session will be send immediately.
If sever processes DELEGRETUEN slowly, destory session maybe processed before.
so that, destory session will be denied with NFS4ERR_DELAY.

NFS client don't care the return value of DESTROY_SESSION,
and call DESTROY_CLIENTID directly, so that, all DESTROY_CLIENTID will fail
with NFS4ERR_CLIENTID_BUSY, retry DESTROY_CLIENTID is usefulness. 

After that, nfs client have destroy all information about nfs server,
but nfs server also records client's information for DESTORY_CLIENTID and 
DESTROY_SESSION failed.

This patch make sure the DESTROY_SESSION/DESTORY_CLIENTID success,
first, cut down the cost of umount as I said above.
second, make sure server clean the recording of client not until expired.

thanks,
Kinglong Mee
