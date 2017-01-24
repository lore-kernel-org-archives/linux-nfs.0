Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:51144 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750732AbdAXHwh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jan 2017 02:52:37 -0500
Date: Tue, 24 Jan 2017 08:52:35 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, bfields@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: setattr ATTR_SIZE vs the rest
Message-ID: <20170124075235.GA16515@lst.de>
References: <1485104060-15209-1-git-send-email-hch@lst.de> <20170123165833.GD9493@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170123165833.GD9493@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 23, 2017 at 11:58:33AM -0500, J. Bruce Fields wrote:
> On Sun, Jan 22, 2017 at 05:54:19PM +0100, Christoph Hellwig wrote:
> > I've got a report that there NFS clients that send SETATTR requests that
> > mix size changes with uid/gid changes
> 
> That sounds a little weird.  Do you know anything about which clients,
> or how common the behavior is?

I've only gotten the bug report and don't know the details.  But from
my cursory knowledge of NFS spec I suspects it's a loosely coupled
flexfiles server that uses uid/gids for access control on the data
file.

> > (see the recent pynfs patch for an
> > artifical reproducer).  At least XFS and GFS2 are very unhappy with this,
> > and other file systems also don't seem to handle the case correctly.
> 
> Does this cause a crash or corruption, or "just" fail to set the
> attributes correctly?  (Just wondering how urgent the fix is....).

With a XFS debug build it crashes, otherwise it "only" fails to set the
attributes.  But given that the attributes that fail to be set are
owner/group (uid,gid) it would totally break the security model, so
I think it's pretty serious.
