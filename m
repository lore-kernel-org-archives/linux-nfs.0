Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx142.netapp.com ([216.240.21.19]:2553 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760103AbbBIPjk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2015 10:39:40 -0500
Message-ID: <54D8D4BA.906@Netapp.com>
Date: Mon, 9 Feb 2015 10:39:38 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 09/11] SUNRPC: Remove TCP socket linger code
References: <1423451262-84493-1-git-send-email-trond.myklebust@primarydata.com>	<1423451262-84493-2-git-send-email-trond.myklebust@primarydata.com>	<1423451262-84493-3-git-send-email-trond.myklebust@primarydata.com>	<1423451262-84493-4-git-send-email-trond.myklebust@primarydata.com>	<1423451262-84493-5-git-send-email-trond.myklebust@primarydata.com>	<1423451262-84493-6-git-send-email-trond.myklebust@primarydata.com>	<1423451262-84493-7-git-send-email-trond.myklebust@primarydata.com>	<1423451262-84493-8-git-send-email-trond.myklebust@primarydata.com>	<1423451262-84493-9-git-send-email-trond.myklebust@primarydata.com>	<1423451262-84493-10-git-send-email-trond.myklebust@primarydata.com>	<54D8D2C3.5000401@Netapp.com> <CAHQdGtQi-TZghQYZzYPOAiRtqSAw0YWSv3z6hCgUEm1usV6uFA@mail.gmail.com>
In-Reply-To: <CAHQdGtQi-TZghQYZzYPOAiRtqSAw0YWSv3z6hCgUEm1usV6uFA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/09/2015 10:37 AM, Trond Myklebust wrote:
> On Mon, Feb 9, 2015 at 10:31 AM, Anna Schumaker
> <Anna.Schumaker@netapp.com> wrote:
>>
>> Hi Trond,
>>
>> On 02/08/2015 10:07 PM, Trond Myklebust wrote:
>>> Now that we no longer use the partial shutdown code when closing the
>>> socket, we no longer need to worry about the TCP linger2 state.
>>
>> Can you also remove the "#define XS_TCP_LINGER_TO" and xs_tcp_fin_timeout from the top of xprtsock.c?  It looks like they don't have any users after this patch.
>>
>> Thanks,
>> Anna
> 
> 
> Technically, those are part of the user ABI (being in the
> xs_tunables_table), so we should probably proceed with care before
> removing them.

Okay.  Maybe at least move xs_tcp_fin_timeout so it's under CONFIG_SUNRPC_DEBUG to match when the tunables_table is defined?

> 
> 
> 

