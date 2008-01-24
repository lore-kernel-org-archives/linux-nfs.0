From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 24 Jan 2008 16:49:53 -0500
Message-ID: <47990801.6050703@redhat.com>
References: <478F78E8.40601@redhat.com> <20080117163105.GG16581@fieldses.org>
	<478F82DA.4060709@redhat.com> <20080117164002.GH16581@fieldses.org>
	<478F9946.9010601@redhat.com> <20080117202342.GA6416@fieldses.org>
	<20080124160030.GB26164@fieldses.org> <4798EAE1.2000707@redhat.com>
	<20080124201910.GF26164@fieldses.org> <4798FDE9.4040406@redhat.com>
	<20080124214029.GK26164@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <20080124214029.GK26164@fieldses.org>
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
> On Thu, Jan 24, 2008 at 04:06:49PM -0500, Wendy Cheng wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Thu, Jan 24, 2008 at 02:45:37PM -0500, Wendy Cheng wrote:
>>>   
>>>       
>>>> J. Bruce Fields wrote:
>>>>     
>>>>         
>>>>> In practice, it seems that both the unlock_ip and unlock_pathname
>>>>> methods that revoke locks are going to be called together.  The two
>>>>> separate calls therefore seem a little redundant.  The reason we *need*
>>>>> both is that it's possible that a misconfigured client could grab locks
>>>>> for a (server ip, export) combination that it isn't supposed to.
>>>>>         
>>>>>           
>>>> That is not a correct assumption. The two commands (unlock_ip and   
>>>> unlock_pathname) are not necessarily called together. It is ok for 
>>>> local  filesystem (ext3) but not for cluster filesystem where the 
>>>> very same  filesystem (or subtree) can be exported from multiple 
>>>> servers using  different subtrees.
>>>>     
>>>>         
>>> Ouch.  Are people really doing that, and why?  What happens if the
>>> subtrees share files (because of hard links) that are locked from both
>>> nodes?
>>>   
>>>       
>> It is *more* common than you would expect - say server1 exports  
>> "/mnt/gfs/maildir/namea-j" and server2 exports 
>> "/mnt/gfs/maildir/namek-z".
>>     
>
> I believe it, but how hard would it be for them to just set those up as
> separate partitions?
>
>   
The answers that I normally hear is that "then why would I bother to use 
a cluster filesystem ?" .... Wendy
