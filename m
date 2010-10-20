From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd rpc service update failures on 2.6.32
Date: Wed, 20 Oct 2010 12:59:10 -0400
Message-ID: <20101020165909.GB2804@fieldses.org>
References: <20101017142918.GA6805@miyako>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jonathan Steinert <hachi-rIxVFxJalAJeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55719 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752894Ab0JTQ7N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 12:59:13 -0400
In-Reply-To: <20101017142918.GA6805@miyako>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 17, 2010 at 07:29:19AM -0700, Jonathan Steinert wrote:
> Hi folks, I've got a machine here that I've been debugging NFS issues on for a week or so now.
> 
> I've boiled the issue down to this:
> 
> Start up the NFS server, this seems to work fine, no errors:
>   rpc.nfsd 1
> 
> Check to see if nfsd has registered with rpcbind, this never shows the nfsd service being registered:
>   rpcinfo -p
> 
> So far I've got the following diagnostics done:
> 
> - Cranked up the debugging in rpcbind, never found SET updates happening (only UNSET)
> - Captured the rpc update frames going over lo, viewed in wireshark. They are all UNSET only
> - Crank up rpcdebug on kernel, only unregister frames are being generated.
> 
> The interesting thing I see is:
> 
> svc: svc_register(nfsdv4, udp, 0, 2)
> RPC:       unregistering [100003, 4, 0.0.0.0.0.0, 'udp'] with local rpcbind
> 
> For some reason svc_register is being called with '0' as the port argument.
> 
> Looking at the ports list in proc says that udp and tcp 2049 are to be used.
> 
> I've been searching around for any information regarding this issue, but haven't found anything. Do any of you folks know if this has been fixed in a later kernel? Is this even a known issue of some kind? I would be testing a newer kernel, but my box has a major issue with some driver as of 2.6.33, which I am also still debugging.
> 
> Not subscribed to this list, please CC me if you can. I'll watch the archives too.

It doesn't ring any bells.  What distro are you using, and how is it
starting nfsd?

--b.
