Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:48967 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675Ab1CVDQr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2011 23:16:47 -0400
Message-ID: <4D88149C.10506@parallels.com>
Date: Mon, 21 Mar 2011 22:16:44 -0500
From: Rob Landley <rlandley@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tim Spriggs <tims@uahirise.org>
Subject: Re: [PATCH] Minimal fix to mount NFS in containers with non-default
 network context.
References: <4D881413.9050807@parallels.com>
In-Reply-To: <4D881413.9050807@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/21/2011 10:14 PM, Rob Landley wrote:
>  fs/nfs/client.c     |    3 ++-
>  fs/nfs/mount_clnt.c |    5 +++--
>  2 files changed, 7 insertions(+), 3 deletions(-)

Sigh.

5 insertions, 3 deletions.  Removed an irrelevant hunk by hand, shoulda
just re-run diffstat...

Rob
