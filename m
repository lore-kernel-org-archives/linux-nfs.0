From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [RFC 0/4] nfs-utils: nfsd support for minor version
Date: Thu, 16 Apr 2009 14:23:13 -0400
Message-ID: <20090416182313.GE450@fieldses.org>
References: <49E2F6E4.2080501@panasas.com> <49E769C5.6010902@RedHat.com> <49E7721E.2070601@panasas.com> <49E7753C.4010300@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:54285 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757419AbZDPSXR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2009 14:23:17 -0400
In-Reply-To: <49E7753C.4010300-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 16, 2009 at 02:13:16PM -0400, Steve Dickson wrote:
> Benny Halevy wrote:
> >> Benny Halevy wrote:
> >>> Steve, please review the following patch that add support
> >>> for controlling the nfsv4 minor version support via
> >>> /proc/fs/nfsd/versions.
> >>>
> >>> [PATCH 1/4] utils/nfsd: fix -N optarg error printout
> >>> 	This patch fixes an existing bug.
> >> This is a bug... and has been committed...
> >>
> >>> [RFC 2/4] utils/nfsd: add support for minorvers4
> >>> 	Under-the-cover support for minorvers4
> >> I see you let minorvers4 default to zero, which means 4.1
> >> support is off by default. Why? As long as we have away to
> >> turn of 4.1 processing (i.e. your 4/4 patch), then I see
> >> no reason we should have the support enabled by default. 

Was there a typo there?  You ask why 4.1 support is off, then say you
see "no reason we should have the support enabled by default."  Those
two statements seem to agree?  Did you mean "no reason we should
not..."?

> > 
> > I was also thinking about using the new nfs-utils with old kernels.
> > Though, these should not puke on seeing [-+]4.1, they'll
> > just interpret it as enabling/disabling v4.
> > I'll test that...
> I just did... Using the '-N 4.1' flag to rpc.nfsd on an older 
> kernel simply turns off all v4 processing... which is fine, IMHO...

If you want v4 running, but don't trust v4.1 yet, and want to use a
mixture of new and old kernels--what configuration will you use?

--b.
