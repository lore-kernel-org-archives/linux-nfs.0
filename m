Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35835 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752830AbbCWWkP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Mar 2015 18:40:15 -0400
Date: Mon, 23 Mar 2015 18:40:13 -0400
From: Mike Snitzer <snitzer@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, Jens Axboe <axboe@fb.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        device-mapper development <dm-devel@redhat.com>,
        linux-mtd@lists.infradead.org, Tejun Heo <tj@kernel.org>,
        ceph-devel@vger.kernel.org, Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 11/12] fs: don't reassign dirty inodes to
 default_backing_dev_info
Message-ID: <20150323224012.GA29505@redhat.com>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-12-git-send-email-hch@lst.de>
 <CAMM=eLe6Tt+g7dLcnn5a1fQboDknkasazsMiOFBziWPZemnYtg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMM=eLe6Tt+g7dLcnn5a1fQboDknkasazsMiOFBziWPZemnYtg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 21 2015 at 11:11am -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Wed, Jan 14, 2015 at 4:42 AM, Christoph Hellwig <hch@lst.de> wrote:
> > If we have dirty inodes we need to call the filesystem for it, even if the
> > device has been removed and the filesystem will error out early.  The
> > current code does that by reassining all dirty inodes to the default
> > backing_dev_info when a bdi is unlinked, but that's pretty pointless given
> > that the bdi must always outlive the super block.
> >
> > Instead of stopping writeback at unregister time and moving inodes to the
> > default bdi just keep the current bdi alive until it is destroyed.  The
> > containing objects of the bdi ensure this doesn't happen until all
> > writeback has finished by erroring out.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reviewed-by: Tejun Heo <tj@kernel.org>
> > ---
> >  mm/backing-dev.c | 91 +++++++++++++++-----------------------------------------
> >  1 file changed, 24 insertions(+), 67 deletions(-)
> 
> Hey Christoph,
> 
> Just a heads up: your commit c4db59d31e39ea067c32163ac961e9c80198fd37
> is suspected as the first bad commit in a bisect performed to track
> down the cause of DM crashes reported in this BZ:
> https://bugzilla.redhat.com/show_bug.cgi?id=1202449
> 
> I've yet to look closely at _why_ this commit but figured I'd share
> since this appears to be a 4.0-rcX regression.

FYI, here is the DM fix I've staged for 4.0-rc6.  I'll continue testing
the various DM targets before requesting Linus to pull.
