From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH 000 of 14] knfsd: Preparation for IPv6 support in NFS server.
Date: Fri, 2 Feb 2007 09:07:47 +0000
Message-ID: <20070202090747.GA27907@infradead.org>
References: <20070202153531.18622.patches@notabene> <adahcu55fiu.fsf@cisco.com> <45C2D3F0.9050907@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>, NeilBrown <neilb@suse.de>,
	Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422695AbXBBJIQ@vger.kernel.org>
In-Reply-To: <45C2D3F0.9050907@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Feb 02, 2007 at 01:02:24AM -0500, Jeff Garzik wrote:
> NFS/RDMA is IMO more than a little bit questionable, and the likely 
> userbase is also quite small.  I'm not sure its worth a mainline merge 
> at this point.

Why do you think so?  In my eyes it's actually one of the few useful
applications for RDMA, especially combined with something like pnfs [*].
Also if you'd look at the patches they're very clean - it's just another
possible transport with almost no invastion to the core code.


[*] yes, the actual pnfs spec is fugly as hell and symptom of the nfsv4
    design by comittee braindamage, but the idea is sound..
