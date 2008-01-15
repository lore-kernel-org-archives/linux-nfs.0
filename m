From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 15 Jan 2008 15:17:09 -0500
Message-ID: <478D14C5.1000804@redhat.com>
References: <4781BB0D.90706@redhat.com>	<20080108170220.GA21401@infradead.org>	<20080108174958.GA25025@infradead.org>	<4783E3C9.3040803@redhat.com>	<20080109180214.GA31071@infradead.org>	<20080110075959.GA9623@infradead.org>	<4788665B.4020405@redhat.com>
	<18315.62909.330258.83038@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Christoph Hellwig <hch@infradead.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Neil Brown <neilb@suse.de>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <18315.62909.330258.83038@notabene.brown>
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

Neil Brown wrote:
> On Saturday January 12, wcheng@redhat.com wrote:
>   
>> This is a combined patch that has:
>>
>> * changes made by Christoph Hellwig
>> * code segment that handles f_locks so we would not walk inode->i_flock 
>> list twice.
>>
>>     
.....
>
> if (unlikely(failover) &&
>     !failover(data, file))
> 	file->f_locks = nlm_file_inuse(file);
> else if (nlm_inspect_file(data, file, match))
> 	ret = 1;
>
> Though the logic still isn't very clear... maybe:
>
> if (likely(failover == NULL) ||
>     failover(data, file))
> 	ret |= nlm_inspect_file(data, file, match);
> else
>     file->f_locks = nlm_file_inuse(file);
>
> Actually I would like to make nlm_inspect_file return 'void'.
> The returned value of '1' is ultimately either ignored or it triggers
> a BUG().  And the case where it triggers a BUG is the "host != NULL"
> case.  (I think - if someone could check, that would be good).
> So putting BUG_ON(host) in nlm_traverse_locks (along with a nice big
> comment) would mean we can discard the return value from
> nlm_traverse_locks and nlm_inspect_file and nlm_traverse_files.
>   

Current logic BUG() when:

1. host is not NULL; and
2. nlm_traverse_locks() somehow can't unlock the file.

I don't feel comfortable to change the existing code structure, 
especially a BUG() statement. It would be better to separate lock 
failover function away from lockd code clean-up. This is to make it 
easier for problem isolations (just in case).

On the other hand, if we view "ret" as a file count that tells us how 
many files fail to get unlocked, it would be great for debugging 
purpose. So the changes I made (currently in the middle of cluster 
testing) end up like this:

if (likely(is_failover_file == NULL) ||
is_failover_file(data, file)) {
/*
* Note that nlm_inspect_file updates f_locks
* and ret is the number of files that can't
* be unlocked.
*/
ret += nlm_inspect_file(data, file, match);
} else
file->f_locks = nlm_file_inuse(file);


>
>
>
>   
>>  
>>  			mutex_lock(&nlm_file_mutex);
>>  			file->f_count--;
>>  			/* No more references to this file. Let go of it. */
>> -			if (list_empty(&file->f_blocks) && !file->f_locks
>> +			if (!file->f_locks && list_empty(&file->f_blocks)
>>     
>
> Is this change actually achieving something?  or is it just noise?
>   
Not really - but I thought checking for f_locks would be faster (tiny 
bit of optimization :))

-- Wendy
>
> NeilBrown
>
>   
