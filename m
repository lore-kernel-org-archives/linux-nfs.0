From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH for stable] Re: [Fwd: moradin 2006-08-02 11:02 System Events]
Date: Thu, 3 Aug 2006 00:16:22 -0700
Message-ID: <20060803071622.GJ26354@kroah.com>
References: <44D08371.9070607@svs.Informatik.Uni-Oldenburg.de> <17617.16700.274788.869486@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philipp Matthias Hahn <pmhahn@svs.Informatik.Uni-Oldenburg.de>,
	akpm@osdl.org, nfs@lists.sourceforge.net, stable@kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932337AbWHCHUu@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17617.16700.274788.869486@cse.unsw.edu.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Aug 03, 2006 at 10:20:12AM +1000, Neil Brown wrote:
> On Wednesday August 2, pmhahn@svs.Informatik.Uni-Oldenburg.de wrote:
> > Hello!
> > 
> > Rebooting one of our NFS file servers with 2.6.17.7, I just got the
> > following OOPS:
> 
> Thanks for the report.
> The bug was fairly easy to find and fix.
> I think this would be appropriate for the next 2.6.17.x stable kernel,
> and definitely for 2.6.18. (hence 'akpm' and 'stable' cc:ed).
> 
> It is not relevant for earlier kernels (e.g. 2.6.16).
> 
> Patch was made against 2.6.18-rc2-mm1, but applies equally to
> 2.6.17.7.

Queued to -stable.

thanks,

greg k-h
