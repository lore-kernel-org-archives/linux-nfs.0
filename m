From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] NFS: Fix a bug in nfs_fscache_release_page()
Date: Mon, 08 Feb 2010 11:39:56 -0500
Message-ID: <1265647196.5235.35.camel@localhost>
References: <1265409793-18314-1-git-send-email-Trond.Myklebust@netapp.com>
	 <4B6EA357.3000604@suse.de>  <1265635435.5235.4.camel@localhost>
	 <1265640621.5235.23.camel@localhost>  <4B703CF6.3020301@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753276Ab0BHQko convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2010 11:40:44 -0500
In-Reply-To: <4B703CF6.3020301@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-02-08 at 22:03 +0530, Suresh Jayaraman wrote: 
> We seem to ensure that we're holding a page lock in try_to_release_page.
> Even if the outstanding commit is complete by the time we are in
> nfs_releage_page, page flags should not have been modified, right?

No. PG_private may be cleared while another process is holding the page
lock (just like PG_writeback may).

Once cleared, PG_private cannot be set again without grabbing the page
lock.

Trond
