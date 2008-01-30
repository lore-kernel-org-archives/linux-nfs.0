From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/3] NLM add resume procfs file
Date: Wed, 30 Jan 2008 11:43:50 -0500
Message-ID: <47A0A946.5030405@redhat.com>
References: <47997059.704@redhat.com> <20080129021910.GF16785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: cluster-devel@redhat.com, NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <20080129021910.GF16785@fieldses.org>
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
>> +	int rc;
>> +
>> +	rc = failover_parse_ip(file, buf, size, &server_ip);
>> +	if (rc < 0)
>> +		return rc;
>>  
>>  	return nlmsvc_failover_ip(server_ip);
>>  }
>>     
>
> Looks great, but it would fit more logically with the previous patch.
> (If you know you're going to end up using this code in two places, may
> as well write it that way from the start.)
>   

The original unlock patch did have a shared routine for this purpose. 
After review, its code structure got changed a little bit. Since the 
revised version has non-trivial amount of testing efforts behind it, I 
think it is better to do the change here, instead of the well-tested 
unlock patch.

On the other hand, I cut the resume patch into three pieces mostly for 
review purpose. Do you think it would be easier (for your git tree 
works) that I combine these three small patches into a big resume patch 
after all the review comments are incorporated into the code ?

-- Wendy
