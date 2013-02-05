Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:36387 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137Ab3BEFgy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2013 00:36:54 -0500
Message-ID: <51109A64.8010904@parallels.com>
Date: Tue, 5 Feb 2013 09:36:36 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
CC: <Trond.Myklebust@netapp.com>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [PATCH v2 0/6] SUNRPC: rework cache upcall to avoid NFSd root
References: <20130204105728.11633.53621.stgit@localhost.localdomain> <20130204141719.GA815@fieldses.org>
In-Reply-To: <20130204141719.GA815@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

04.02.2013 18:17, J. Bruce Fields пишет:
> On Mon, Feb 04, 2013 at 02:02:29PM +0300, Stanislav Kinsbursky wrote:
>> swapping
>>
>> The main idea of this patch set is to call cache request not on kthread
>> upcall, but on userspace daemon cache_read call. This fixes the problem with
>> gaining of wrong dentry path after calling d_path() in kthread root context
>> (svc_export_request() callback), which always work in init root context, but
>> containers can work in "root jail" - i.e. have it's own nested root.
>>
>> v2:
>> 1) NFS DNS cache update wasn't done in the firest version. So this patch set
>> does preparation cleanup of the NFS DNS cache routines.
>> 2) Also, this patch set doesn't remove cache_upcall helper anymore, because
>> it's still required for NFS DNS cache.
>
> Argh--I really prefer incremental patches once I've already committed
> something, but OK.
>

Sorry. I was thinking about incremental patches. Next time I'll do so.

> Backing out the old patches, I'll take a look at these.  The first two
> should probably get an ACK from Trond.
>

Trond, could you review first two patches, please?
They are just clean-ups, actually. Nothing special. Required to unify the interfaces for latter patches in the series.

-- 
Best regards,
Stanislav Kinsbursky
