From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Fri, 18 Jan 2008 11:21:07 +0100
Message-ID: <20080118102107.GB26106@janus>
References: <20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com> <18315.62909.330258.83038@notabene.brown> <478D14C5.1000804@redhat.com> <18317.7319.443532.62244@notabene.brown> <478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org> <478F78E8.40601@redhat.com> <478F7D96.1060602@redhat.com> <478F7DE4.30404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:58038 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754673AbYARKVJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 05:21:09 -0500
In-Reply-To: <478F7DE4.30404@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> shell> echo 10.1.1.2 > /proc/fs/nfsd/unlock_ip
> shell> echo /mnt/sfs1 > /proc/fs/nfsd/unlock_filesystem
> 
> The expected sequence of events can be:
> 1. Tear down the IP address

You might consider using iptables at this point for dropping outgoing
packets with that source IP address to catch any packet still in
flight. It fixed ESTALE problems for me IIRC (NFSv3, UDP).

> 2. Unexport the path
> 3. Write IP to /proc/fs/nfsd/unlock_ip to unlock files
> 4. If unmount required, write path name to
>    /proc/fs/nfsd/unlock_filesystem, then unmount.
> 5. Signal peer to begin take-over.
> 

-- 
Frank
