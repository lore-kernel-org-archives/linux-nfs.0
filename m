Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55156 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750812AbeAPPmM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Jan 2018 10:42:12 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: backchannel tracepoint expects rpc_clnt
Date: Tue, 16 Jan 2018 10:42:10 -0500
Message-ID: <48F5E023-E77A-405A-8C0D-920555E4D2F0@redhat.com>
In-Reply-To: <892E802C-67CA-4F5C-A9F4-D36271A154C3@redhat.com>
References: <892E802C-67CA-4F5C-A9F4-D36271A154C3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16 Jan 2018, at 10:31, Benjamin Coddington wrote:

> Hi Trond,
>
> I'm trying to get to the bottom of a backchannel problem, but with
> tracepoints enabled things blow up in trace_rpc_task_sleep() because 
> there's
> no rpc_clnt (or easy way to get to one) on a backchannel request.
>
> The only reason we're sending the rpc_clnt to that tracepoint is to 
> emit the
> cl_clid:
>
> commit 2f048db4680ae19da13df15d352ac02748781ecb
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Wed Sep 4 21:51:44 2013 -0400
>
>     SUNRPC: Add an identifier for struct rpc_clnt
>
>     Add an identifier in order to aid debugging.
>
> Can we rather just use the address of the struct rpc_clnt rather than 
> an
> integer in the tracepoint?

Well, I suppose we can just do it the same way trace_rpc_task_running() 
does
it, which is with:

89     TP_fast_assign(
90         __entry->client_id = clnt ? clnt->cl_clid : -1;

I'll send a patch for that..

Ben
