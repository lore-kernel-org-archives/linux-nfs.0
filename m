From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 2/3] NLM per-ip grace period - core
Date: Tue, 29 Jan 2008 12:10:32 -0500
Message-ID: <479F5E08.5050807@redhat.com>
References: <479970EA.2060900@redhat.com> <20080129025656.GH16785@fieldses.org>
	<514B944F-02FC-4164-BFDA-209361F4BD25@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	cluster-devel@redhat.com, NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <514B944F-02FC-4164-BFDA-209361F4BD25@oracle.com>
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

Chuck Lever wrote:
> On Jan 28, 2008, at 9:56 PM, J. Bruce Fields wrote:
>> On Fri, Jan 25, 2008 at 12:17:30AM -0500, Wendy Cheng wrote:
>>
>>> The logic is implemented on top of linux nfsd procfs with core 
>>> functions
>>> residing in lockd kernel module. Entry function is 
>>> nlmsvc_resume_ip() where
>>> it stores the requested ip interface into a linked-list 
>>> nlm_failover_list.
>>> The list entry count is nlm_failover_cnt and access protection is 
>>> done by
>>> nlm_failover_mutex. Entry in nlm_failover_ip_list is a 
>>> "nlm_failover_struct",
>>> defined in: include/linux/lockd/lockd.h.
>>>
>>>
>>> +struct nlm_failover_struct {
>>> + struct list_head g_list; /* linked list */
>>> + unsigned long g_expire; /* grace period expire */
>>> + int g_size; /* g_key type: ipv4 or ipv6 */
>>> + union {
>>> + __be32 ipv4; /* ip v4 address */
>>> + __be32 ipv6[4]; /* ip v6 address */
>>> + } g_key;
>>> +#define g_ip g_key.ipv6
>>> +};
>>
>> Only the second member of that union is every used; could we just get
>> rid of the union?
>>
>> Also, is that the right choice of types? Maybe we should just use
>> struct in6_addr?
>
> I agree with Bruce -- just use in_addr, and leave out the unused IPv6 
> stuff for now.
>
> In some places, we just replace in_addr with in6_addr and simply map 
> IPv4 to IPv6 addresses, rather than setting up a union.
>
> If the address is used as a hash and never displayed, using a mapped 
> IPv4 address is sufficient, and keeps things simple.

ok, I have been yo-yoing about whether doing IPv6 support. This sounds 
like a good plan. Will do.

-- Wendy
