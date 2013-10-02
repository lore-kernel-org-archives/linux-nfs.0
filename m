Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f175.google.com ([209.85.215.175]:53836 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781Ab3JBORY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 10:17:24 -0400
Received: by mail-ea0-f175.google.com with SMTP id m14so431257eaj.34
        for <linux-nfs@vger.kernel.org>; Wed, 02 Oct 2013 07:17:23 -0700 (PDT)
Message-ID: <524C2AF0.4000602@primarydata.com>
Date: Wed, 02 Oct 2013 17:17:20 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 43/49] pnfsd: release state lock around iput in
 put_nfs4_file
References: <52447EA0.7070004@primarydata.com> <1380220968-14669-1-git-send-email-bhalevy@primarydata.com> <20130929121903.GF21083@infradead.org> <524ACEA9.1040304@primarydata.com> <20131001133739.GA13149@infradead.org>
In-Reply-To: <20131001133739.GA13149@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-01 16:37, Christoph Hellwig wrote:
> On Tue, Oct 01, 2013 at 04:31:21PM +0300, Benny Halevy wrote:
>> So the reason not to hold it is that the nfs state lock is global to the
>> server and blocks all state modifying operations such as:
>> open, close, lock, clientid, session operations, etc.
> 
> While not really related to this patch: what's the reason it's not
> split?  The way nfsd works there should be almost no state that isn't
> per-export.

I'll defer to Bruce.  We did reduce the use of the state_lock in the past
but I think there is potential for further reducing what it covers.

Memory allocations for client, file, stateid etc. and can be optimized for
the common path by opportunistically allocating these after a quick
search (lockless of rcu_read is possible)
In the uncommon case insertion of the newly allocated stuff would fail and
they will be freed.

The candidates I can quickly see are:
- the idr calls manipulating and looking up the different stateid hash tables,
- clientid rb_trees, and
- file hash table
  - currently protected with the recall_lock spin_lock but we can factor out,
    I think, the call to nfsd4_alloc_file and combine find_file and nfsd4_init_file
    for conditional insertion under the recall_lock.

Benny


> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
