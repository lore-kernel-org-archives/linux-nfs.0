Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:38823
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752576Ab1ITQTd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 12:19:33 -0400
Date: Tue, 20 Sep 2011 12:19:33 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] statd: Decouple statd's state directory from the NFS
 state directory
Message-ID: <20110920161932.GA10040@infradead.org>
References: <1316531020-25071-1-git-send-email-steved@redhat.com>
 <20110920154011.GA6959@infradead.org>
 <4E78BC72.40303@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E78BC72.40303@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 20, 2011 at 12:16:50PM -0400, Steve Dickson wrote:
> > What is thje rationale for this?  And who would want to move it at
> > compile time, not at run time?
> It all has to do with statd not running as root... 
> 
> During the rpm installation, a state directory is created and 
> the uid/gid are set to rpcuser id. When statd fires up, those
> uid/gids are obtained and used to set the process's uid/gid so
> the daemon does not run as root..
> 
> The default NFS state directory is /var/lib/nfs. Since other
> processes, like mountd and exportfs, read and write to that,
> we don't want to muck around with its ownership. So a statd 
> directory is created and the ownership of that directory 
> is mucked with.

Shouldn't the configure option then be about running statd non-root
and all things required for it?  E.g. do the set*uid, creating the
new dir with the right owner and permissions, and using it?

