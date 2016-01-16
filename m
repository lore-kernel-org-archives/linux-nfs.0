Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33409 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbcAPV65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Jan 2016 16:58:57 -0500
Subject: Re: [PATCH nfs-utils 0/2] Fix problems caused by rpc.statd being
 unresponsive.
To: NeilBrown <neilb@suse.com>
References: <20151217042613.7581.1566.stgit@noble>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <569ABD20.7040003@RedHat.com>
Date: Sat, 16 Jan 2016 16:58:56 -0500
MIME-Version: 1.0
In-Reply-To: <20151217042613.7581.1566.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/16/2015 11:27 PM, NeilBrown wrote:
> If rpc.statd is temporarily unresponsive (e.g. because DNS service is
> slow) it can cause mount attempts to fail inappropriately or can cause
> multiple rpc.statd processes to be running on the one machine.
> 
> These patches address those problems.
> 
> ---
> 
> NeilBrown (2):
>       mount.nfs: trust the exit status of "start_statd".
>       start-statd: don't run multiple rpc.statds on the one host.
Both patches committed.... again.. thank you!

steved
> 
> 
>  utils/mount/network.c   |    6 +++++-
>  utils/statd/start-statd |    8 ++++++++
>  2 files changed, 13 insertions(+), 1 deletion(-)
> 
> --
> Signature
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
