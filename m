From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Wed, 16 Jan 2008 15:19:17 +1100
Message-ID: <18317.34245.222866.193544@notabene.brown>
References: <4781BB0D.90706@redhat.com>
	<20080108170220.GA21401@infradead.org>
	<20080108174958.GA25025@infradead.org>
	<4783E3C9.3040803@redhat.com>
	<20080109180214.GA31071@infradead.org>
	<20080110075959.GA9623@infradead.org>
	<4788665B.4020405@redhat.com>
	<18315.62909.330258.83038@notabene.brown>
	<478D14C5.1000804@redhat.com>
	<18317.7319.443532.62244@notabene.brown>
	<478D3820.9080402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:49605 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753186AbYAPETZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 23:19:25 -0500
In-Reply-To: message from Wendy Cheng on Tuesday January 15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday January 15, wcheng@redhat.com wrote:
> Revised version of the patch:
> 
> * based on comment from Neil Brown, use sscanf() to parse IP address (a 
> cool idea imo).
> * the "ret" inside nlm_traverse_files() is now the file count that can't 
> be unlocked.
> * other minor changes from latest round of review.
> 
> Thanks to all for the review !
> 
> -- Wendy
> 
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
> Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-By: NeilBrown <neilb@suse.de>

Thanks.

NeilBrown
