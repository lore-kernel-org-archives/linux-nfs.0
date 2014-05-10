Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57305 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaEJFKU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 May 2014 01:10:20 -0400
Date: Fri, 9 May 2014 22:10:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFSD: Don't clear SUID/SGID after root writing data
Message-ID: <20140510051017.GA23444@infradead.org>
References: <534AA92B.8010805@gmail.com>
 <20140418130220.GF18612@fieldses.org>
 <53512DE5.7050907@gmail.com>
 <5351501B.1010507@gmail.com>
 <20140508161256.GC20976@fieldses.org>
 <536C89D7.6090902@gmail.com>
 <20140509214056.GC497@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140509214056.GC497@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 09, 2014 at 05:40:57PM -0400, J. Bruce Fields wrote:
> On Fri, May 09, 2014 at 03:55:03PM +0800, Kinglong Mee wrote:
> > On 5/9/2014 00:12, J. Bruce Fields wrote:
> > > I'd like to apply this if only to remove the redundant code.
> > > 
> > > I'd like to understand, though, whether this is something that caused an
> > > actual practical problem for someone, or if you just happened to notice
> > > the inconsistency between nfs and ext4 behavior?
> > 
> > I test it with ext2,ext3,btrfs,xfs.
> > Test result is same as ext4.
> > So, we needs remove the redundant killing of suid/sgid.
> 
> Understood that this would make the behavior consistent with
> filesystems.  But, you don't know of any cases of the current behavior
> is actually causing a problem for anyone?


I thin this also is the root cause for xfstests generic/193 failing on
NFS, but I haven't verified it yet.
