Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48053 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756420AbbHZNBe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Aug 2015 09:01:34 -0400
Date: Wed, 26 Aug 2015 15:00:57 +0200
From: David Sterba <dsterba@suse.cz>
To: Peng Tao <tao.peng@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>, linux-btrfs@vger.kernel.org,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH RFC 02/11] vfs/btrfs: add .clone_range file operation
Message-ID: <20150826130057.GW10756@suse.cz>
Reply-To: dsterba@suse.cz
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
 <1440516829-116041-3-git-send-email-tao.peng@primarydata.com>
 <20150826080111.GV10756@twin.jikos.cz>
 <CAKVebiWy6S4ri8_V+SuT+mnyTKjiubPS49k3LHF2Csh2TVf_SQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiWy6S4ri8_V+SuT+mnyTKjiubPS49k3LHF2Csh2TVf_SQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 04:31:09PM +0800, Peng Tao wrote:
> >> -#define BTRFS_IOC_CLONE        _IOW(BTRFS_IOCTL_MAGIC, 9, int)
> >
> > The ioctl definition reuses the BTRFS_IOCTL_MAGIC (0x94), which is IMHO
> > wrong.
> >
> I thought it breaks ABI if we choose a different value for the type
> field of the ioctl. Am I misunderstanding it?

The ioctl is now private to btrfs, you're going to define the new ABI so
it IMHO should use the generic filesystem ioctl magic/namespace.
