Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:36810 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbHZNHU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 09:07:20 -0400
Date: Wed, 26 Aug 2015 06:07:12 -0700
From: Christoph Hellwig <hch@infradead.org>
To: dsterba@suse.cz, Peng Tao <tao.peng@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>, linux-btrfs@vger.kernel.org,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH RFC 02/11] vfs/btrfs: add .clone_range file operation
Message-ID: <20150826130712.GA6958@infradead.org>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
 <1440516829-116041-3-git-send-email-tao.peng@primarydata.com>
 <20150826080111.GV10756@twin.jikos.cz>
 <CAKVebiWy6S4ri8_V+SuT+mnyTKjiubPS49k3LHF2Csh2TVf_SQ@mail.gmail.com>
 <20150826130057.GW10756@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150826130057.GW10756@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 03:00:57PM +0200, David Sterba wrote:
> > I thought it breaks ABI if we choose a different value for the type
> > field of the ioctl. Am I misunderstanding it?
> 
> The ioctl is now private to btrfs, you're going to define the new ABI so
> it IMHO should use the generic filesystem ioctl magic/namespace.

No, that's completly backwards.  We move up ioctls that have prooven
to be generally useful to common code, and we've done that with various
extN and XFS ones already.
