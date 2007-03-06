From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 004 of 4] knfsd: Provide sunrpc pool_mode module option
Date: Mon, 5 Mar 2007 20:57:57 -0800
Message-ID: <20070305205757.2d5db738.akpm@linux-foundation.org>
References: <20070306131103.26638.patches@notabene>
	<1070306021520.26937@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752192AbXCFE6L@vger.kernel.org>
In-Reply-To: <1070306021520.26937@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 6 Mar 2007 13:15:20 +1100 NeilBrown <neilb@suse.de> wrote:

> Provide a module param "pool_mode" for sunrpc.ko which allows a
> sysadmin to choose the mode for mapping NFS thread service pools
> to CPUs.  Values are:
> 
> auto	    choose a mapping mode heuristically
> global	    (default, same as the pre-2.6.19 code) a single global pool
> percpu	    one pool per CPU
> pernode	    one pool per NUMA node
> 
> Note that since 2.6.19 the hardcoded behaviour has been "auto",
> this patch makes the default "global".
> 
> The pool mode can be changed after boot/modprobe using /sys, if the
> NFS and lockd services have been shut down.  A useful side effect of
> this change is to fix a small memory leak when unloading the module.

Mutter.  Is this really suitable and needed for 2.6.21 at this stage in
its life?
