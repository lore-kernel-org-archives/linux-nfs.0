Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19595 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbbHZQW3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 12:22:29 -0400
Date: Wed, 26 Aug 2015 09:21:54 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: dsterba@suse.cz, Peng Tao <tao.peng@primarydata.com>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH-RFC-RESEND 1/9] vfs: pull btrfs clone API to vfs layer
Message-ID: <20150826162154.GD10038@birch.djwong.org>
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
 <1440577010-122867-2-git-send-email-tao.peng@primarydata.com>
 <20150826133723.GX10756@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150826133723.GX10756@twin.jikos.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 03:37:23PM +0200, David Sterba wrote:
> On Wed, Aug 26, 2015 at 04:16:42PM +0800, Peng Tao wrote:
> > +struct file_clone_range {
> > +	__s64 src_fd;
> > +	__u64 src_offset;
> > +	__u64 src_length;
> > +	__u64 dest_offset;
> > +};
> 
> Might be a good idea to add some spare bytes to the structure.

But... structure size is encoded in the ioctl definition, so adding bytes
to struct file_clone_range now will change the ioctl number and break
userland.

--D

> 
> >  struct fstrim_range {
> >  	__u64 start;
> >  	__u64 len;
> > @@ -159,6 +166,8 @@ struct inodes_stat_t {
> >  #define FIFREEZE	_IOWR('X', 119, int)	/* Freeze */
> >  #define FITHAW		_IOWR('X', 120, int)	/* Thaw */
> >  #define FITRIM		_IOWR('X', 121, struct fstrim_range)	/* Trim */
> > +#define FICLONE		_IOW(0x94, 9, int)	/* Clone */
> > +#define FICLONERANGE	_IOW(0x94, 13, struct file_clone_range)	/* Clone range */
> 
> FICLONE is a special case of FICLONERANGE. The whole file clone had come
> historically first and then was refined, I don't think this needs to be
> copied to the generic API. A zeroed file_clone_range is simple to use
> for that purpose.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
