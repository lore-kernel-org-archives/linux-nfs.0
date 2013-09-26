Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281Ab3IZOsT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 10:48:19 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20130926144517.29424.12036.stgit@warthog.procyon.org.uk>
References: <20130926144517.29424.12036.stgit@warthog.procyon.org.uk> <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, bfields@fieldses.org, Trond.Myklebust@netapp.com,
        olof@lixom.net, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/4] SunRPC: Declare and use rpc_task_pid() to wrap task->tk_pid
Date: Thu, 26 Sep 2013 15:48:07 +0100
Message-ID: <29702.1380206887@warthog.procyon.org.uk>
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> Declare and use rpc_task_pid() to wrap task->tk_pid (when it exists) and to
> return 0 when it doesn't.  This allows us to move towards using no_printk().
> 
> This was mostly achieved with:
> 
>    perl -p -i -e 's/task->tk_pid/rpc_task_pid(task)/g' `git grep -l 'task->tk_pid'`
>    perl -p -i -e 's/data->task.tk_pid/rpc_task_pid(&data->task)/g' `git grep -l 'data->task.tk_pid'`

I missed one command out.  This needs to be done first:

	perl -p -i -e 's/req->rq_task->tk_pid/rpc_task_pid(req->rq_task)/g' `git grep -l 'req->rq_task->tk_pid'`

David
