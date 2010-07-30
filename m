From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/5] nfsd: bypass readahead cache when have struct file
Date: Fri, 30 Jul 2010 04:25:23 -0400
Message-ID: <20100730082523.GA21128@infradead.org>
References: <1280442084-17867-1-git-send-email-bfields@redhat.com>
 <1280442084-17867-2-git-send-email-bfields@redhat.com>
 <20100730081041.GA4126@infradead.org>
 <4C528AFF.5020806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	"J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
To: Bian Naimeng <biannm@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:43747 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755135Ab0G3IZa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jul 2010 04:25:30 -0400
In-Reply-To: <4C528AFF.5020806@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 30, 2010 at 04:19:11PM +0800, Bian Naimeng wrote:
> > which suggests that we're better off just calling nfsd_open_read
> > (possible with a better name) directly from fs/nfsd/nfs3proc.c and
> > fs/nfsd/nfsproc.c and nfsd_vfs_read directly from fs/nfsd/nfs4proc.c
> > and fs/nfsd/nfs4xdr.c instead of doing this conditional.
> > 
> 
>   As bruce said, it should not be used for NFSv4. 

Please read the above sentence again.

