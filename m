From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 15 Jan 2008 11:30:59 -0500
Message-ID: <20080115163059.GA17937@fieldses.org>
References: <4781BB0D.90706@redhat.com> <20080108170220.GA21401@infradead.org> <20080108174958.GA25025@infradead.org> <4783E3C9.3040803@redhat.com> <20080109180214.GA31071@infradead.org> <20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com> <20080114230742.GA16975@fieldses.org> <478CDBFE.4080905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, NeilBrown <neilb@suse.de>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440AbYAOQbE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 11:31:04 -0500
In-Reply-To: <478CDBFE.4080905@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 15, 2008 at 11:14:54AM -0500, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>>>  +static ssize_t failover_unlock_ip(struct file *file, char *buf, 
>>> size_t size)
>>> +{
>>> +	__be32 server_ip;
>>> +	char *fo_path;
>>> +	char *mesg;
>>> +
>>> +	/* sanity check */
>>> +	if (size <= 0)
>>> +		return -EINVAL;
>>>     
>>
>> Not only is size never negative, it's actually an unsigned type here, so
>> this is a no-op.
>>   
>
> Based on comment from Neil, let's keep this ?

Yes, I misread, apologies!

>>   
>>> +
>>> +	server_ip = in_aton(fo_path);
>>>     
>>
>> It'd be nice if we could sanity-check this.  (Is there code already in
>> the kernel someplace to do this?)
>>   
>
> The argument here is that if this is a bogus address, the search (of nlm  
> files list) will fail (not found) later anyway.

Or it could accidentally find some other address?

> Failover is normally  
> time critical. Quicker we finish, less issues will be seen. The sanity  
> check here can be skipped (imo).

>> And, this isn't your problem for now, but eventually I guess this will
>> have to accept an ivp6 address as well?
>>   
>
> yeah .. Thinking about this right now.. May be borrowing the code from  
> ip_map_parse() as Neil pointed out in another mail ?

Yes, that looks easy enough.

I think the sanity checking would make it easier to extend the interface
later (for ipv6 or whatever else we might discover we need) because
we'll be able to depend on older kernels failing in a predictable way.

--b.
