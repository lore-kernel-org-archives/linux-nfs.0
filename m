Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62562 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758432Ab3ENWEq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 18:04:46 -0400
Date: Tue, 14 May 2013 15:04:40 -0700
From: Zach Brown <zab@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [RFC v0 0/4] sys_copy_range() rough draft
Message-ID: <20130514220440.GN16385@lenny.home.zabbo.net>
References: <1368566126-17610-1-git-send-email-zab@redhat.com>
 <20130514214251.GK29466@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130514214251.GK29466@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 15, 2013 at 07:42:51AM +1000, Dave Chinner wrote:
> On Tue, May 14, 2013 at 02:15:22PM -0700, Zach Brown wrote:
> > I'm going to keep hacking away at this.  My next step is to get ext4
> > supporting .copy_range, probably with a quick hack to copy the
> > contents of bios.  Hopefully that'll give enough time to also integrate
> > review feedback.
> 
> Wouldn't the easiest "support all filesystems" hack just be to add
> a destination offset parameter to do_splice_direct() and call that
> when the filesystem doesn't supply a ->copy_range method? i.e. use
> the mechanisms we already have for copying from one file to another
> via the page cache as efficiently as possible?

Probably; and this in-kernel buffered fallback is particularly desirable
for nfsd when the exported fs doesn't provide .copy_range.  Having nfsd
service the COPY op is still a significant win over having the client
move the data backand forth over the wire.

But in that quote above I was talking about implementing .copy_range in
ext4 as though it could use XCOPY today.  I'd like to get a feel for how
bad it's going to be to juggle the bio XCOPY IO with unwritten extent
conversion, RMW with overlapping existing blocks, i_size advancing, etc.
(It's so much like O_DIRECT that I'm already crying a little.)

- z
