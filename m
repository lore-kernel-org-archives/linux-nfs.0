Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbcAPV54 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Jan 2016 16:57:56 -0500
Subject: Re: [PATCH nfs-utils 0/2] fixes for protocol fallback on mount
To: NeilBrown <neilb@suse.com>
References: <20151217015524.19978.63114.stgit@noble>
Cc: linux-nfs@vger.kernel.org, Andreas Schwab <schwab@suse.com>,
        Takashi Iwai <tiwai@suse.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <569ABCE3.9060909@RedHat.com>
Date: Sat, 16 Jan 2016 16:57:55 -0500
MIME-Version: 1.0
In-Reply-To: <20151217015524.19978.63114.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/16/2015 08:56 PM, NeilBrown wrote:
> Two unrelated patches which both relate to protocol fallback
> when mounting an NFS filesystem.
> 
> ---
> 
> Andreas Schwab (1):
>       Fix uninitialised variable usage in nfs_options2pmap
> 
> NeilBrown (1):
>       Fix protocol minor version fall-back
Both patches committed! Thank you!!

steved.

> 
> 
>  utils/mount/network.c |    5 ++++-
>  utils/mount/stropts.c |    3 +++
>  2 files changed, 7 insertions(+), 1 deletion(-)
> 
> --
> Signature
> 
