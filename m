Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42413 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbbFEP7l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2015 11:59:41 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 3/6] SUNRPC: Clean up bc_send()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHVgHyWz-dKX-6TbRCYRBp7b2uV2-kCd7U63sHd5ZKZKr6e7aw@mail.gmail.com>
Date: Fri, 5 Jun 2015 12:02:11 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B30A41CC-EADC-4738-8FDF-E8B03AAA48FC@oracle.com>
References: <1433453213-13466-1-git-send-email-trond.myklebust@primarydata.com> <1433453213-13466-2-git-send-email-trond.myklebust@primarydata.com> <1433453213-13466-3-git-send-email-trond.myklebust@primarydata.com> <CAHVgHyWz-dKX-6TbRCYRBp7b2uV2-kCd7U63sHd5ZKZKr6e7aw@mail.gmail.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 5, 2015, at 11:50 AM, Andy Adamson <androsadamson@gmail.com> wrote:

> On Thu, Jun 4, 2015 at 5:26 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> From: Chuck Lever <chuck.lever@oracle.com>
>> 
>> Clean up: Merge bc_send() into bc_svc_process().
>> 
>> Note: even thought this touches svc.c, it is a client-side change.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>> include/linux/sunrpc/bc_xprt.h |  1 -
>> net/sunrpc/Makefile            |  2 +-
>> net/sunrpc/bc_svc.c            | 63 ------------------------------------------
>> net/sunrpc/svc.c               | 33 ++++++++++++++++------
>> 4 files changed, 26 insertions(+), 73 deletions(-)
>> delete mode 100644 net/sunrpc/bc_svc.c
>> 
>> diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
>> index 2ca67b55e0fe..8df43c9f11dc 100644
>> --- a/include/linux/sunrpc/bc_xprt.h
>> +++ b/include/linux/sunrpc/bc_xprt.h
>> @@ -37,7 +37,6 @@ void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied);
>> void xprt_free_bc_request(struct rpc_rqst *req);
>> int xprt_setup_backchannel(struct rpc_xprt *, unsigned int min_reqs);
>> void xprt_destroy_backchannel(struct rpc_xprt *, unsigned int max_reqs);
>> -int bc_send(struct rpc_rqst *req);
>> 
>> /*
>>  * Determine if a shared backchannel is in use
>> diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
>> index 15e6f6c23c5d..1b8e68d0e690 100644
>> --- a/net/sunrpc/Makefile
>> +++ b/net/sunrpc/Makefile
>> @@ -15,6 +15,6 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
>>            sunrpc_syms.o cache.o rpc_pipe.o \
>>            svc_xprt.o
>> sunrpc-$(CONFIG_SUNRPC_DEBUG) += debugfs.o
>> -sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o bc_svc.o
>> +sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o
>> sunrpc-$(CONFIG_PROC_FS) += stats.o
>> sunrpc-$(CONFIG_SYSCTL) += sysctl.o
>> diff --git a/net/sunrpc/bc_svc.c b/net/sunrpc/bc_svc.c
>> deleted file mode 100644
>> index 15c7a8a1c24f..000000000000
>> --- a/net/sunrpc/bc_svc.c
>> +++ /dev/null
>> @@ -1,63 +0,0 @@
>> -/******************************************************************************
>> -
>> -(c) 2007 Network Appliance, Inc.  All Rights Reserved.
>> -(c) 2009 NetApp.  All Rights Reserved.
>> -
>> -NetApp provides this source code under the GPL v2 License.
>> -The GPL v2 license is available at
>> -http://opensource.org/licenses/gpl-license.php.
>> -
>> -THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
>> -"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
>> -LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
>> -A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
>> -CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
>> -EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
>> -PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
>> -PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
>> -LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
>> -NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
>> -SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>> -
>> -******************************************************************************/
> 
> Why is the above being removed?

Hi Andy-

Interesting question, and IANAL.

Where should the boilerplate go if the below function is merged into
existing generic server code? I suppose we could fold the NetApp
copyright into the comment at the top of net/sunrpc/svc.c , but the
merged code is paraphrased rather than copied directly.

Suggestions/opinions are welcome.


> -->Andy
> 
>> -
>> -/*
>> - * The NFSv4.1 callback service helper routines.
>> - * They implement the transport level processing required to send the
>> - * reply over an existing open connection previously established by the client.
>> - */
>> -
>> -#include <linux/module.h>
>> -
>> -#include <linux/sunrpc/xprt.h>
>> -#include <linux/sunrpc/sched.h>
>> -#include <linux/sunrpc/bc_xprt.h>
>> -
>> -#define RPCDBG_FACILITY        RPCDBG_SVCDSP
>> -
>> -/* Empty callback ops */
>> -static const struct rpc_call_ops nfs41_callback_ops = {
>> -};
>> -
>> -
>> -/*
>> - * Send the callback reply
>> - */
>> -int bc_send(struct rpc_rqst *req)
>> -{
>> -       struct rpc_task *task;
>> -       int ret;
>> -
>> -       dprintk("RPC:       bc_send req= %p\n", req);
>> -       task = rpc_run_bc_task(req, &nfs41_callback_ops);
>> -       if (IS_ERR(task))
>> -               ret = PTR_ERR(task);
>> -       else {
>> -               WARN_ON_ONCE(atomic_read(&task->tk_count) != 1);
>> -               ret = task->tk_status;
>> -               rpc_put_task(task);
>> -       }
>> -       dprintk("RPC:       bc_send ret= %d\n", ret);
>> -       return ret;
>> -}
>> -
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index 78974e4d9ad2..e144902d382e 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -1350,6 +1350,11 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
>> {
>>        struct kvec     *argv = &rqstp->rq_arg.head[0];
>>        struct kvec     *resv = &rqstp->rq_res.head[0];
>> +       static const struct rpc_call_ops reply_ops = { };
>> +       struct rpc_task *task;
>> +       int error;
>> +
>> +       dprintk("svc: %s(%p)\n", __func__, req);
>> 
>>        /* Build the svc_rqst used by the common processing routine */
>>        rqstp->rq_xprt = serv->sv_bc_xprt;
>> @@ -1372,21 +1377,33 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
>> 
>>        /*
>>         * Skip the next two words because they've already been
>> -        * processed in the trasport
>> +        * processed in the transport
>>         */
>>        svc_getu32(argv);       /* XID */
>>        svc_getnl(argv);        /* CALLDIR */
>> 
>> -       /* Returns 1 for send, 0 for drop */
>> -       if (svc_process_common(rqstp, argv, resv)) {
>> -               memcpy(&req->rq_snd_buf, &rqstp->rq_res,
>> -                                               sizeof(req->rq_snd_buf));
>> -               return bc_send(req);
>> -       } else {
>> -               /* drop request */
>> +       /* Parse and execute the bc call */
>> +       if (!svc_process_common(rqstp, argv, resv)) {
>> +               /* Processing error: drop the request */
>>                xprt_free_bc_request(req);
>>                return 0;
>>        }
>> +
>> +       /* Finally, send the reply synchronously */
>> +       memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
>> +       task = rpc_run_bc_task(req, &reply_ops);
>> +       if (IS_ERR(task)) {
>> +               error = PTR_ERR(task);
>> +               goto out;
>> +       }
>> +
>> +       WARN_ON_ONCE(atomic_read(&task->tk_count) != 1);
>> +       error = task->tk_status;
>> +       rpc_put_task(task);
>> +
>> +out:
>> +       dprintk("svc: %s(), error=%d\n", __func__, error);
>> +       return error;
>> }
>> EXPORT_SYMBOL_GPL(bc_svc_process);
>> #endif /* CONFIG_SUNRPC_BACKCHANNEL */
>> --
>> 2.4.2
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



