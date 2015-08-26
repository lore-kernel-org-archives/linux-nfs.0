Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34582 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754238AbbHZQhL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Aug 2015 12:37:11 -0400
Date: Wed, 26 Aug 2015 18:36:33 +0200
From: David Sterba <dsterba@suse.cz>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Peng Tao <tao.peng@primarydata.com>, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH-RFC-RESEND 1/9] vfs: pull btrfs clone API to vfs layer
Message-ID: <20150826163633.GC10756@suse.cz>
Reply-To: dsterba@suse.cz
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
 <1440577010-122867-2-git-send-email-tao.peng@primarydata.com>
 <20150826133723.GX10756@twin.jikos.cz>
 <20150826162154.GD10038@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150826162154.GD10038@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 09:21:54AM -0700, Darrick J. Wong wrote:
> On Wed, Aug 26, 2015 at 03:37:23PM +0200, David Sterba wrote:
> > On Wed, Aug 26, 2015 at 04:16:42PM +0800, Peng Tao wrote:
> > > +struct file_clone_range {
> > > +	__s64 src_fd;
> > > +	__u64 src_offset;
> > > +	__u64 src_length;
> > > +	__u64 dest_offset;
> > > +};
> > 
> > Might be a good idea to add some spare bytes to the structure.
> 
> But... structure size is encoded in the ioctl definition, so adding bytes
> to struct file_clone_range now will change the ioctl number and break
> userland.

Oh right, I somehow did not left idea of a new ioctl definition while
writing it.
