Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754311AbbAONNc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jan 2015 08:13:32 -0500
Date: Thu, 15 Jan 2015 08:13:23 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Paul van der Vlis <paul@vandervlis.nl>
cc: linux-nfs@vger.kernel.org
Subject: Re: Max. open files?
In-Reply-To: <m98a90$bh8$1@ger.gmane.org>
Message-ID: <alpine.OSX.2.19.9992.1501150805380.27935@planck.local>
References: <m98a90$bh8$1@ger.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Paul van der Vlis,

I don't think there's a NFSD limit on open files, but you'd be subject to
VFS' file-max.

http://lxr.free-electrons.com/source/Documentation/sysctl/fs.txt#L91

Ben

On Thu, 15 Jan 2015, Paul van der Vlis wrote:

> Hello,
>
> Is there in nfs-kernel-server a maximum on the open files?
>
> If yes, what's the correct way to change that maximum?
>
> Do I get errors in the logs when the maximum is reached?
>
> With regards,
> Paul van der Vlis.
>
>
> --
> Paul van der Vlis Linux systeembeheer, Groningen
> http://www.vandervlis.nl/
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
