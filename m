Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43886 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754795AbaJ2HAD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2014 03:00:03 -0400
Date: Wed, 29 Oct 2014 14:59:36 +0800
From: Eryu Guan <eguan@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] common: re-enable tests that require scratch dev on
 NFS
Message-ID: <20141029065936.GK14167@dhcp-13-216.nay.redhat.com>
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>
 <1414502171-10319-2-git-send-email-eguan@redhat.com>
 <20141028132252.GA26453@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141028132252.GA26453@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 28, 2014 at 06:22:52AM -0700, Christoph Hellwig wrote:
> On Tue, Oct 28, 2014 at 09:16:08PM +0800, Eryu Guan wrote:
> > index 747cf72..8738da7 100644
> > --- a/common/rc
> > +++ b/common/rc
> > @@ -558,7 +558,11 @@ _scratch_mkfs()
> >          _scratch_mkfs_xfs $*
> >  	;;
> >      nfs*)
> > -	# do nothing for nfs
> > +	# unable to re-create NFS, just remove all files in $SCRATCH_MNT to
> > +	# avoid EEXIST caused by the leftover files created in previous runs
> > +	_scratch_mount
> > +	rm -rf $SCRATCH_MNT/*
> > +	_scratch_unmount
> 
> Please move this into a helper, and wire it up for cifs as well.
> 

Will do in v2.

Thanks for the review!

Eryu
