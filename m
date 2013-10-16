Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f41.google.com ([74.125.82.41]:53422 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674Ab3JPIVc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 04:21:32 -0400
Received: by mail-wg0-f41.google.com with SMTP id b13so4431280wgh.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Oct 2013 01:21:30 -0700 (PDT)
Message-ID: <525E4C88.9050701@primarydata.com>
Date: Wed, 16 Oct 2013 11:21:28 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: bfields@redhat.com, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: state lock elimination
References: <20131015211445.GA23636@infradead.org> <525DB943.3010707@primarydata.com> <20131016064243.GA28758@infradead.org>
In-Reply-To: <20131016064243.GA28758@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-16 09:42, Christoph Hellwig wrote:
>> A lot of crap ended up under the client_mutex that we need to untangle.
>> My general direction is:
>> - use a spin lock for all non-blocking sections (rename recall_lock to state_lock for that)
> 
> Any chance we can avoid global locks for most of this?  Global locks
> really suck for scalability, and in nfsd we should be able to do most
> things per-export at least.
> 

I tried reducing the lock scope but the problem is that we hash state
on objects with different scopes of access, particularly net/client vs. file
and the hashing needs to be consistent and atomic.

>> - for state mutating nfs4 ops like open/close/lock/... use wait_on_bit to serialize access
>>   *per open owner* rather than globally.
> 
> per open owner sounds good.  Not a huge fan of bit locks as they make
> debugging very hard, though.

I'll try using a refcount and mutex first as per Bruce's current direction with stateowners.

> 
> I'll look over your changes soon, btw.
> 

Thanks!

The WIP version is in git://linux-nfs/~bhalevy/linux-pnfs.git state-lock-elim
if anyone else is interested in previewing the patchset in its current drafty state)

Benny
