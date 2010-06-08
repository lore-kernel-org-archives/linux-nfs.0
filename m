From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 2/8] pnfs-submit: clean locking infrastructure
Date: Tue, 08 Jun 2010 10:34:59 +0300
Message-ID: <4C0DF2A3.3030006@panasas.com>
References: <1275945113-3436-1-git-send-email-batsakis@netapp.com> <1275945113-3436-2-git-send-email-batsakis@netapp.com> <1275945113-3436-3-git-send-email-batsakis@netapp.com> <20100608073053.GA12121@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexandros Batsakis <batsakis@netapp.com>,
	linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46464 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657Ab0FHHfF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 03:35:05 -0400
Received: by bwz11 with SMTP id 11so1099022bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jun 2010 00:35:03 -0700 (PDT)
In-Reply-To: <20100608073053.GA12121@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-06-08 10:30, Christoph Hellwig wrote:
> On Mon, Jun 07, 2010 at 02:11:47PM -0700, Alexandros Batsakis wrote:
>> +static inline void lock_current_layout(struct nfs_inode *nfsi)
>> +{
>> +	spin_lock(&nfsi->lo_lock);
>> +}
>> +
>> +static inline void unlock_current_layout(struct nfs_inode *nfsi)
>> +{
>> +	BUG_ON_UNLOCKED_LO((&nfsi->layout));
>> +	spin_unlock(&nfsi->lo_lock);
>> +}
> 
> Adding wrappers for these is nothing but obsfucation.  No need
> for the BUG_ON above, the spinlock code asserts that already if
> building with spinlock debugging.

Good point.
