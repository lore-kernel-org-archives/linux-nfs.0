From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 17 Jan 2008 11:31:22 -0500
Message-ID: <478F82DA.4060709@redhat.com>
References: <4783E3C9.3040803@redhat.com>
	<20080109180214.GA31071@infradead.org>
	<20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com>
	<18315.62909.330258.83038@notabene.brown>
	<478D14C5.1000804@redhat.com>
	<18317.7319.443532.62244@notabene.brown>
	<478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org>
	<478F78E8.40601@redhat.com> <20080117163105.GG16581@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <20080117163105.GG16581@fieldses.org>
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
> On Thu, Jan 17, 2008 at 10:48:56AM -0500, Wendy Cheng wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> Remind me: why do we need both per-ip and per-filesystem methods?  In
>>> practice, I assume that we'll always do *both*?
>>>   
>>>       
>> Failover normally is done via virtual IP address - so per-ip base method  
>> should be the core routine. However, for non-cluster filesystem such as  
>> ext3/4, changing server also implies umount. If there are clients not  
>> following rule and obtaining locks via different ip interfaces, umount  
>> would fail that ends up aborting the failover process. That's the place  
>> we need the per-filesystem method.
>>
>> ServerA:
>> 1. Tear down the IP address
>> 2. Unexport the path
>> 3. Write IP to /proc/fs/nfsd/unlock_ip to unlock files
>> 4. If unmount required,
>> write path name to /proc/fs/nfsd/unlock_filesystem, then unmount.
>> 5. Signal peer to begin take-over.
>>
>> Sometime ago we were looking at "export name" as the core method (so  
>> per-filesystem method is a subset of that). Unfortunately, the prototype  
>> efforts showed the code would be too intrusive (if filesystem sub-tree  
>> is exported).
>>     
>>> We're migrating clients by moving a server ip address from one node to
>>> another.  And I assume we're permitting at most one node to export each
>>> filesystem at a time.  So it *should* be the case that the set of locks
>>> held on the filesystem(s) that are moving are the same as the set of
>>> locks held by the virtual ip that is moving.
>>>   
>>>       
>> This is true for non-cluster filesystem. But a cluster filesystem can be  
>> exported from multiple servers.
>>     
>
> But that last sentence:
>
> 	it *should* be the case that the set of locks held on the
> 	filesystem(s) that are moving are the same as the set of locks
> 	held by the virtual ip that is moving.
>
> is still true in the cluster filesystem case, right?
>
> --b.
>   
Yes .... Wendy
