From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [solved] Re: [PATCH] Short write in nfsd becomes a full write
	to the client
Date: Tue, 30 Jun 2009 11:22:50 -0400
Message-ID: <20090630152250.GD17840@fieldses.org>
References: <20090627042449.GC15665@cupro.opengvs.com> <20090629145952.GE4945@fieldses.org> <20090629192951.GA3851@cupro.opengvs.com> <20090629194711.GF8062@fieldses.org> <20090629194925.GG8062@fieldses.org> <20090630152209.GA3320@cupro.opengvs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, David Shaw <dshaw-wh+mT2OhP0WF0gnf/s2wvA@public.gmane.org>
To: Dale Stimson <DaleStimson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 174-143-236-118.static.slicehost.net ([174.143.236.118]:46820
	"EHLO fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179AbZF3PWr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jun 2009 11:22:47 -0400
In-Reply-To: <20090630152209.GA3320-NmLOIDrUSDQtrE7AZYN0JQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 30, 2009 at 08:22:09AM -0700, Dale Stimson wrote:
> On Mon, Jun 29, 2009 at 03:49:25PM -0400, J. Bruce Fields wrote:
> > After looking at the trace: yes, looks like the same problem.  (The
> > (succesful) FILE_SYNC write request returned with a 0 length.)  So
> > retest with the new patch applied, then poke the Fedora people to apply
> > it as well.
> > 
> > --b.
> 
> Success.
> 
> I applied patch a0d24b295aed7a9daf4ca36bd4784e4d40f82303
> "nfsd: fix hung up of nfs client while sync write data to nfs server"
> to the otherwise unmodified Fedora 11 kernel 2.6.29.5-191.fc11.i686.PAE
> and the problem was resolved.
> 
> Thank you for your help.  I will update
> https://bugzilla.redhat.com/show_bug.cgi?id=508174
> and suggest that the patch be applied to future Fedora 2.6.29-based kernels.

Thanks for following up.--b.
