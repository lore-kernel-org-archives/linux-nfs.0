From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Upgrade to 2.6.24 breaks NFS service
Date: Wed, 13 Feb 2008 02:19:12 -0800
Message-ID: <20080213021912.b127c4a7.akpm@linux-foundation.org>
References: <87lk5pjkro.fsf@hades.wkstn.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Nix <nix@esperi.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40685 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752197AbYBMKUt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2008 05:20:49 -0500
In-Reply-To: <87lk5pjkro.fsf-x0esd30BCtidcjFyoUV/Pg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(cc linux-nfs)

On Wed, 13 Feb 2008 08:58:03 +0000 Nix <nix@esperi.org.uk> wrote:

> I upgraded from 2.6.23.10 to 2.6.24.2 yesterday, and found NFS service
> failing.
> 
> To be specific, all locks were blocking forever, with an endless flood
> of
> 
> Feb 12 22:53:10 loki notice: kernel: statd: server localhost not responding, timed out
> Feb 12 22:53:10 loki notice: kernel: lockd: cannot monitor esperi
> Feb 12 22:53:45 loki notice: kernel: statd: server localhost not responding, timed out
> Feb 12 22:53:45 loki notice: kernel: lockd: cannot monitor esperi
> Feb 12 22:54:20 loki notice: kernel: statd: server localhost not responding, timed out
> Feb 12 22:54:20 loki notice: kernel: lockd: cannot monitor esperi
> Feb 12 22:54:55 loki notice: kernel: statd: server localhost not responding, timed out
> Feb 12 22:54:55 loki notice: kernel: lockd: cannot monitor esperi
> Feb 12 22:55:20 esperi notice: kernel: lockd: server loki.wkstn.nix not responding, still trying
> 
> (esperi is a UML instance on the same machine, connected via a bridged
> TUN/TAP interface: the bridge, and network service to esperi and to the
> rest of the local net across that bridge, was fine.)
> 
> I'm currently using NFSv3 atop nfs-utils 1.1.0.33-gdd08789, with daemons
> being started in the suggested order (portmap, mountd, statd
> --no-notify, nfsd). This evening I'm going to try to upgrade to
> nfs-utils HEAD and see if this continues.
> 

