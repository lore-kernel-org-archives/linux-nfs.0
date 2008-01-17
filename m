From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 17 Jan 2008 12:59:38 -0500
Message-ID: <478F978A.6010906@redhat.com>
References: <20080110075959.GA9623@infradead.org>	
	<4788665B.4020405@redhat.com>
	<18315.62909.330258.83038@notabene.brown>	
	<478D14C5.1000804@redhat.com>
	<18317.7319.443532.62244@notabene.brown>	
	<478D3820.9080402@redhat.com>
	<20080117151007.GB16581@fieldses.org>	 <478F78E8.40601@redhat.com>
	<20080117163105.GG16581@fieldses.org>	
	<478F82DA.4060709@redhat.com> <20080117164002.GH16581@fieldses.org>
	<1200591323.13670.34.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, NFS list <linux-nfs@vger.kernel.org>,
	cluster-devel@redhat.com, Christoph Hellwig <hch@infradead.org>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1200591323.13670.34.camel@dyn9047022153>
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

Frank Filz wrote:
>
> I assume the intent here with this implementation is that the node
> taking over will start lock recovery for the ip address? With that
> perspective, I guess it would be important that each file system only be
> accessed with a single ip address otherwise lock recovery will not work
> correctly since another node/ip could accept locks for that filesystem,
> possibly "stealing" a lock that is in recovery. As I recall, our
> implementation put the entire filesystem cluster-wide into recovery
> during fail-over.
>
>   

We have 2 more patches on their way to this mailing that:

* Set per-ip based grace period
* Notify only relevant clients about reclaim events

-- Wendy
