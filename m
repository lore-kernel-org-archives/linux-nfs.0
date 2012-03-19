Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29133 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106Ab2CST12 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 15:27:28 -0400
Received: from vmwexceht03-prd.hq.netapp.com (vmwexceht03-prd.hq.netapp.com [10.106.76.241])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q2JJRDfQ005747
	for <linux-nfs@vger.kernel.org>; Mon, 19 Mar 2012 12:27:13 -0700 (PDT)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: We must not use list_for_each_entry_safe() in
 rpc_wake_up()
Date: Mon, 19 Mar 2012 19:27:11 +0000
Message-ID: <0EBE6EDB-5D4F-4354-ACBD-3A8C584408E8@netapp.com>
References: <1332181002-10302-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1332181002-10302-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Andy Adamson<andros@netapp.com>

-->Andy

On Mar 19, 2012, at 2:16 PM, Trond Myklebust wrote:

> The problem is that for the case of priority queues, we
> have to assume that __rpc_remove_wait_queue_priority will move new
> elements from the tk_wait.links lists into the queue->tasks[] list.
> We therefore cannot use list_for_each_entry_safe() on queue->tasks[],
> since that will skip these new tasks that __rpc_remove_wait_queue_priority
> is adding.
> 
> Without this fix, rpc_wake_up and rpc_wake_up_status will both fail
> to wake up all functions on priority wait queues, which can result
> in some nasty hangs.
> 
> Reported-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: stable@vger.kernel.org
> ---
> net/sunrpc/sched.c |   15 +++++++++++----
> 1 files changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 1c570a8..994cfea 100644
> --- a/net/sunrpc/sched.c

> +++ b/net/sunrpc/sched.c
> @@ -534,14 +534,18 @@ EXPORT_SYMBOL_GPL(rpc_wake_up_next);
>  */
> void rpc_wake_up(struct rpc_wait_queue *queue)
> {
> -	struct rpc_task *task, *next;
> 	struct list_head *head;
> 
> 	spin_lock_bh(&queue->lock);
> 	head = &queue->tasks[queue->maxpriority];
> 	for (;;) {
> -		list_for_each_entry_safe(task, next, head, u.tk_wait.list)
> +		while (!list_empty(head)) {
> +			struct rpc_task *task;
> +			task = list_first_entry(head,
> +					struct rpc_task,
> +					u.tk_wait.list);
> 			rpc_wake_up_task_queue_locked(queue, task);
> +		}
> 		if (head == &queue->tasks[0])
> 			break;
> 		head--;
> @@ -559,13 +563,16 @@ EXPORT_SYMBOL_GPL(rpc_wake_up);
>  */
> void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
> {
> -	struct rpc_task *task, *next;
> 	struct list_head *head;
> 
> 	spin_lock_bh(&queue->lock);
> 	head = &queue->tasks[queue->maxpriority];
> 	for (;;) {
> -		list_for_each_entry_safe(task, next, head, u.tk_wait.list) {
> +		while (!list_empty(head)) {
> +			struct rpc_task *task;
> +			task = list_first_entry(head,
> +					struct rpc_task,
> +					u.tk_wait.list);
> 			task->tk_status = status;
> 			rpc_wake_up_task_queue_locked(queue, task);
> 		}
> -- 
> 1.7.7.6
> 

