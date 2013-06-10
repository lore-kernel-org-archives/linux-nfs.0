Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:60951 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472Ab3FJOlv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jun 2013 10:41:51 -0400
Message-ID: <51B5E59E.1000501@parallels.com>
Date: Mon, 10 Jun 2013 18:41:34 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, <devel@openvz.org>,
        <linux-kernel@vger.kernel.org>, <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] SUNRPC: PipeFS races fixes
References: <20130610143725.7498.72391.stgit@localhost.localdomain>
In-Reply-To: <20130610143725.7498.72391.stgit@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series has flaws. Will fix and resend.
Sorry for noise.

10.06.2013 18:39, Stanislav Kinsbursky пишет:
> This series fixed races between PipeFS mount/umount notification calls and
> SUNRPC clients creation and destruction.
>
> https://bugzilla.redhat.com/show_bug.cgi?id=924649
>
> The following series implements...
>
> ---
>
> Stanislav Kinsbursky (3):
>        SUNRPC: fix races on PipeFS UMOUNT notifications
>        SUNRPC: fix races on PipeFS UMOUNT notifications
>        SUNRPC: PipeFS MOUNT notification optimization for dying clients
>
>
>   net/sunrpc/clnt.c     |   14 +++++++++-----
>   net/sunrpc/rpc_pipe.c |    5 ++++-
>   2 files changed, 13 insertions(+), 6 deletions(-)
>


-- 
Best regards,
Stanislav Kinsbursky
