From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Sat, 12 Jan 2008 09:38:10 +0000
Message-ID: <20080112093810.GB9059@infradead.org>
References: <4781BB0D.90706@redhat.com> <20080108170220.GA21401@infradead.org> <20080108174958.GA25025@infradead.org> <4783E3C9.3040803@redhat.com> <20080109180214.GA31071@infradead.org> <20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, NeilBrown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46372 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759362AbYALJiQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Jan 2008 04:38:16 -0500
In-Reply-To: <4788665B.4020405@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 12, 2008 at 02:03:55AM -0500, Wendy Cheng wrote:
> This is a combined patch that has:
>
> * changes made by Christoph Hellwig
> * code segment that handles f_locks so we would not walk inode->i_flock 
> list twice.
>
> If agreed, please re-add your "ack-by" and "signed-off" lines respectively. 
> Thanks ...
>
> -- Wendy

> Two new NFSD procfs files are added:
>   /proc/fs/nfsd/unlock_ip
>   /proc/fs/nfsd/unlock_filesystem
> 
> They are intended to allow admin or user mode script to release NLM locks
> based on either a path name or a server in-bound ip address (ipv4 for now)
> as;
> 
> shell> echo 10.1.1.2 > /proc/fs/nfsd/unlock_ip
> shell> echo /mnt/sfs1 > /proc/fs/nfsd/unlock_filesystem
> 
> Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
> Signed-off-by: Lon Hohberger  <lhh@redhat.com>

Signed-off-by: Christoph Hellwig <hch@lst.de>

