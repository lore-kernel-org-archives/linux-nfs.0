From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 17 Jan 2008 11:17:08 -0500
Message-ID: <478F7F84.4040909@redhat.com>
References: <4783E3C9.3040803@redhat.com>
	<20080109180214.GA31071@infradead.org>
	<20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com>
	<18315.62909.330258.83038@notabene.brown>
	<478D14C5.1000804@redhat.com>
	<18317.7319.443532.62244@notabene.brown>
	<478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org>
	<478F78E8.40601@redhat.com> <20080117161415.GE16581@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <20080117161415.GE16581@fieldses.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> Yeah, sounds good.  Maybe under Documentation/filesystems?  And it might
> also be helpful to leave a reference to it in the code, e.g., in
> nfsctl.c:
>
> 	/*
> 	 * The following are used for failover; see
> 	 * Documentation/filesystems/nfsd-failover.txt for details.
> 	 */
>
> --b.
>   

ok, looks good ... but let's "fix" this on the resume patch ? or you 
want it on the unlock patch *now* ?

-- Wendy
