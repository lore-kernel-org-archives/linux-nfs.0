Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx143.netapp.com ([216.240.21.24]:45683 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759473AbbBIVbx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2015 16:31:53 -0500
Message-ID: <54D92746.2020700@Netapp.com>
Date: Mon, 9 Feb 2015 16:31:50 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: Give parameter names to rpc_count_iostasts_metrics()
References: <1423508838-1806-1-git-send-email-Anna.Schumaker@Netapp.com> <EB593CD6-EF0C-42FA-A6BD-C3D9C7DD51F9@primarydata.com>
In-Reply-To: <EB593CD6-EF0C-42FA-A6BD-C3D9C7DD51F9@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/09/2015 04:30 PM, Tom Haynes wrote:
> 
>> On Feb 9, 2015, at 11:07 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>
>> We fall back to an empty function in the case that CONFIG_PROC_FS=n, so
>> give this function named parameters to silence a "parameter name omitted"
>> warning.
>>
>> Reported-by: Jim Davis <jim.epost@gmail.com>
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>> ---
>> include/linux/sunrpc/metrics.h | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/metrics.h b/include/linux/sunrpc/metrics.h
>> index 7e61a17..b23b8ed 100644
>> --- a/include/linux/sunrpc/metrics.h
>> +++ b/include/linux/sunrpc/metrics.h
>> @@ -89,8 +89,8 @@ void			rpc_free_iostats(struct rpc_iostats *);
>> static inline struct rpc_iostats *rpc_alloc_iostats(struct rpc_clnt *clnt) { return NULL; }
>> static inline void rpc_count_iostats(const struct rpc_task *task,
>> 				     struct rpc_iostats *stats) {}
> 
> Hi Anna,
> 
> Why doesn’t the above also emit the warning?

Because the parameters have names: in rpc_count_iostats you have an rpc_task named "task" and an rpc_iostats named "stats".

Anna

> 
> Thanks,
> Tom
> 
> 
>> -static inline void rpc_count_iostats_metrics(const struct rpc_task *,
>> -					     struct rpc_iostats *) {}
>> +static inline void rpc_count_iostats_metrics(const struct rpc_task *task,
>> +					     struct rpc_iostats *op_metrics) {}
>> static inline void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt) {}
>> static inline void rpc_free_iostats(struct rpc_iostats *stats) {}
>>
>> -- 
>> 2.3.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

