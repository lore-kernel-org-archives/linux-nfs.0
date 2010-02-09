From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH 1/2] NFS: Fix a bug in nfs_fscache_release_page()
Date: Tue, 09 Feb 2010 11:56:14 +0530
Message-ID: <4B710006.7070704@suse.de>
References: <1265409793-18314-1-git-send-email-Trond.Myklebust@netapp.com>	 <4B6EA357.3000604@suse.de>  <1265635435.5235.4.camel@localhost>	 <1265640621.5235.23.camel@localhost>  <4B703CF6.3020301@suse.de> <1265647196.5235.35.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:35524 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253Ab0BIG0W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 01:26:22 -0500
In-Reply-To: <1265647196.5235.35.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/08/2010 10:09 PM, Trond Myklebust wrote:
> On Mon, 2010-02-08 at 22:03 +0530, Suresh Jayaraman wrote: 
>> We seem to ensure that we're holding a page lock in try_to_release_page.
>> Even if the outstanding commit is complete by the time we are in
>> nfs_releage_page, page flags should not have been modified, right?
> 
> No. PG_private may be cleared while another process is holding the page
> lock (just like PG_writeback may).
> 
> Once cleared, PG_private cannot be set again without grabbing the page
> lock.
> 

Ah, ok. I got stuck there. Thanks for the clarifying.


-- 
Suresh Jayaraman
