From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Fri, 18 Jan 2008 10:00:00 -0500
Message-ID: <4790BEF0.1020507@redhat.com>
References: <20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com>
	<18315.62909.330258.83038@notabene.brown>
	<478D14C5.1000804@redhat.com>
	<18317.7319.443532.62244@notabene.brown>
	<478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org>
	<478F78E8.40601@redhat.com> <478F7D96.1060602@redhat.com>
	<478F7DE4.30404@redhat.com> <20080118102107.GB26106@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, NFS list <linux-nfs@vger.kernel.org>,
	cluster-devel@redhat.com, Christoph Hellwig <hch@infradead.org>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <20080118102107.GB26106@janus>
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

Frank van Maarseveen wrote:
>> shell> echo 10.1.1.2 > /proc/fs/nfsd/unlock_ip
>> shell> echo /mnt/sfs1 > /proc/fs/nfsd/unlock_filesystem
>>
>> The expected sequence of events can be:
>> 1. Tear down the IP address
>>     
>
> You might consider using iptables at this point for dropping outgoing
> packets with that source IP address to catch any packet still in
> flight. It fixed ESTALE problems for me IIRC (NFSv3, UDP).
>   

ok, thanks ... Wendy
>   
>> 2. Unexport the path
>> 3. Write IP to /proc/fs/nfsd/unlock_ip to unlock files
>> 4. If unmount required, write path name to
>>    /proc/fs/nfsd/unlock_filesystem, then unmount.
>> 5. Signal peer to begin take-over.
>>
>>     
>
>   
