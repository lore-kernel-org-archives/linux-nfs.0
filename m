Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:48768 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980AbbAOPM5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jan 2015 10:12:57 -0500
Date: Thu, 15 Jan 2015 16:12:54 +0100
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Race in bl_resolve_deviceid?
Message-ID: <20150115151254.GA13124@lst.de>
References: <CAHQdGtTqYi0krW6b9w0Bxe-UJkP1nPZEJdCEMYb5XTA91rBtLw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTqYi0krW6b9w0Bxe-UJkP1nPZEJdCEMYb5XTA91rBtLw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 14, 2015 at 11:51:37AM -0500, Trond Myklebust wrote:
> Hi Christoph,
> 
> bl_resolve_deviceid() has:
> 
>         add_wait_queue(&nn->bl_wq, &wq);
>         rc = rpc_queue_upcall(nn->bl_device_pipe, msg);
>         if (rc < 0) {
>                 remove_wait_queue(&nn->bl_wq, &wq);
>                 goto out_free_data;
>         }
> 
>         set_current_state(TASK_UNINTERRUPTIBLE);
>         schedule();
>         remove_wait_queue(&nn->bl_wq, &wq);
> 
> 
> Doesn't that call to 'set_current_state()' need to come before the
> rpc_queue_upcall() if you want the wait for the downcall to be
> race-free? It looks to me as if the right thing to do here is to
> replace the above with a prepare_to_wait()/finish_wait() pair...

That code predates my involvement with the block layout driver,
but from a quick inspecion I'd say you're right.  Let me cook up
a patch and run it through testing.
