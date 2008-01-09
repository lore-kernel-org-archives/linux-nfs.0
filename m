From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Wed, 9 Jan 2008 11:13:37 -0500
Message-ID: <20080109161337.GA9628@fieldses.org>
References: <4781BB0D.90706@redhat.com> <20080108170220.GA21401@infradead.org>
	<4784443D.4070801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, cluster-devel@redhat.com,
	NFS list <linux-nfs@vger.kernel.org>
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <4784443D.4070801@redhat.com>
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

On Tue, Jan 08, 2008 at 10:49:17PM -0500, Wendy Cheng wrote:
> Christoph Hellwig wrote:
>
>>> +/* cluster failover support */
>>> +
>>> +typedef struct {
>>> +	int     cmd;
>>> +	int     stat;
>>> +	int     gp;
>>> +	void    *datap;
>>> +} nlm_fo_cmd;
>>>    
>>>
>>
>> please don't introduce typedefs for struct types.
>>  
>>
>
> I don't do much community version of linux code so its coding standard  
> is new to me. Any reason for this (not doing typedefs) ?

The argument is in "Chapter 5: Typdefs" of Documentation/CodingStyle.

--b.
