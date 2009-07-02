From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFSD: Don't hold unrefcounted creds over call to
	nfsd_setuser()
Date: Thu, 2 Jul 2009 19:09:55 -0400
Message-ID: <20090702230955.GB12376@fieldses.org>
References: <20090702203937.GA10504@fieldses.org> <20090702133532.28297.89635.stgit@warthog.procyon.org.uk> <575.1246570293@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 174-143-236-118.static.slicehost.net ([174.143.236.118]:52048
	"EHLO fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbZGBXJ4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2009 19:09:56 -0400
In-Reply-To: <575.1246570293@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 02, 2009 at 10:31:33PM +0100, David Howells wrote:
> J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > Got it, thanks.  How easy is it to hit this case?  (Just wondering
> > whether to submit for stable.)
> 
> Actually, one of the problems with it is that the file is opened using the old
> creds, cached across the call to nfsd_setuser().

Oops, got it.  That answers that question....

--b.
