From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] NLM add resume procfs file
Date: Fri, 1 Feb 2008 12:24:31 -0500
Message-ID: <20080201172431.GE4798@fieldses.org>
References: <47997059.704@redhat.com> <20080129021910.GF16785@fieldses.org>
	<47A0A946.5030405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cluster-devel@redhat.com, NFS list <linux-nfs@vger.kernel.org>
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <47A0A946.5030405@redhat.com>
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

On Wed, Jan 30, 2008 at 11:43:50AM -0500, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>>> +	int rc;
>>> +
>>> +	rc = failover_parse_ip(file, buf, size, &server_ip);
>>> +	if (rc < 0)
>>> +		return rc;
>>>   	return nlmsvc_failover_ip(server_ip);
>>>  }
>>>     
>>
>> Looks great, but it would fit more logically with the previous patch.
>> (If you know you're going to end up using this code in two places, may
>> as well write it that way from the start.)
>>   
>
> The original unlock patch did have a shared routine for this purpose.  
> After review, its code structure got changed a little bit. Since the  
> revised version has non-trivial amount of testing efforts behind it, I  
> think it is better to do the change here, instead of the well-tested  
> unlock patch.
>
> On the other hand, I cut the resume patch into three pieces mostly for  
> review purpose. Do you think it would be easier (for your git tree  
> works) that I combine these three small patches into a big resume patch  
> after all the review comments are incorporated into the code ?

As long as they each compile and run without introducing any new bugs
(even temporarily) along the way, then I'll almost always prefer more
smaller patches to fewer larger ones.

--b.
