Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:39846 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389Ab2K2LyC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 06:54:02 -0500
Message-ID: <50B74CCB.9080000@parallels.com>
Date: Thu, 29 Nov 2012 15:53:47 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
Subject: Re: NFSd in container - it works
References: <50B64628.4070007@parallels.com> <20121128200126.GA17875@fieldses.org> <20121128152813.2b4c388d@tlielax.poochiereds.net>
In-Reply-To: <20121128152813.2b4c388d@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

29.11.2012 00:28, Jeff Layton пишет:
> On Wed, 28 Nov 2012 15:01:26 -0500
> "bfields@fieldses.org" <bfields@fieldses.org> wrote:
>
>>> 3) Holding net by tracker looks redundant. What was the reason for this?
>>
>> I don't understand, what's tracker?
>
> I assume he means the clientid tracker. That was necessary for the
> nfsdcld upcall because it used rpc_pipefs files, and those were
> net-namespacified. Once we deprecate that in 3.10, I don't think we'll
> need to worry about the net namespace in the clientid tracker.
>

Sorry, I don't understand. Rpc_pipefs superblock already holds network namespace.

> We probably *will* need to concern ourselves with the mnt namespace
> there though since each container will presumably have its own clientid
> database...

Since NFSd server in network namespace based, it means, that we can create one server for more than one mount namespace.
And clietid tracker holds files opened. Thus holds mount.
Mount namespace itself doesn't look that important to me.
Or I'm wrong?

-- 
Best regards,
Stanislav Kinsbursky
