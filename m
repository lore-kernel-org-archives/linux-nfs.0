Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44856 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756613Ab3EOUYE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 16:24:04 -0400
Date: Wed, 15 May 2013 16:24:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Zach Brown <zab@redhat.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC v0 4/4] nfs, nfsd: rough sys_copy_range and COPY support
Message-ID: <20130515202401.GE25994@fieldses.org>
References: <1368566126-17610-1-git-send-email-zab@redhat.com>
 <1368566126-17610-5-git-send-email-zab@redhat.com>
 <20130515201949.GD25994@fieldses.org>
 <1368649314.3568.19.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368649314.3568.19.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 15, 2013 at 08:21:54PM +0000, Myklebust, Trond wrote:
> On Wed, 2013-05-15 at 16:19 -0400, J. Bruce Fields wrote:
> > On Tue, May 14, 2013 at 02:15:26PM -0700, Zach Brown wrote:
> > > This crude patch illustrates the simplest plumbing involved in
> > > supporting sys_call_range with the NFS COPY operation that's pending in
> > > the 4.2 draft spec.
> > > 
> > > The patch is based on a previous prototype that used the COPY op to
> > > implement sys_copyfileat which created a new file (based on the ocfs2
> > > reflink ioctl).  By contrast, this copies file contents between existing
> > > files.
> > > 
> > > There's still a lot of implementation and testing to do, but this can
> > > get discussion going.
> > 
> > I'm using:
> > 
> > 	git://github.com/loghyr/NFSv4.2
> > 
> > as my reference for the draft protocol.
> > 
> > On a quick skim, one thing this is missing before it complies is a
> > client implementation of CB_OFFLOAD: "If a client desires an
> > intra-server file copy, then it MUST support the COPY and CB_OFFLOAD
> > operations."
> 
> Note that Bryan is currently working on updating the NFS implementation
> to match the draft protocol.

OK, good.--b.
