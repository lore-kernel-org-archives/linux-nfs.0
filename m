From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 08 Jan 2008 22:49:17 -0500
Message-ID: <4784443D.4070801@redhat.com>
References: <4781BB0D.90706@redhat.com> <20080108170220.GA21401@infradead.org>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: cluster-devel@redhat.com, NFS list <linux-nfs@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <20080108170220.GA21401@infradead.org>
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

Christoph Hellwig wrote:

>>+/* cluster failover support */
>>+
>>+typedef struct {
>>+	int     cmd;
>>+	int     stat;
>>+	int     gp;
>>+	void    *datap;
>>+} nlm_fo_cmd;
>>    
>>
>
>please don't introduce typedefs for struct types.
>  
>

I don't do much community version of linux code so its coding standard 
is new to me. Any reason for this (not doing typedefs) ?

-- Wendy
