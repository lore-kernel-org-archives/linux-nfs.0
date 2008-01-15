From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Wed, 16 Jan 2008 07:50:31 +1100
Message-ID: <18317.7319.443532.62244@notabene.brown>
References: <4781BB0D.90706@redhat.com>
	<20080108170220.GA21401@infradead.org>
	<20080108174958.GA25025@infradead.org>
	<4783E3C9.3040803@redhat.com>
	<20080109180214.GA31071@infradead.org>
	<20080110075959.GA9623@infradead.org>
	<4788665B.4020405@redhat.com>
	<18315.62909.330258.83038@notabene.brown>
	<478D14C5.1000804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:55923 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757333AbYAOUuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 15:50:44 -0500
In-Reply-To: message from Wendy Cheng on Tuesday January 15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday January 15, wcheng@redhat.com wrote:
> 
> I don't feel comfortable to change the existing code structure, 
> especially a BUG() statement. It would be better to separate lock 
> failover function away from lockd code clean-up. This is to make it 
> easier for problem isolations (just in case).

Fair enough.

> 
> On the other hand, if we view "ret" as a file count that tells us how 
> many files fail to get unlocked, it would be great for debugging 
> purpose. So the changes I made (currently in the middle of cluster 
> testing) end up like this:
> 
> if (likely(is_failover_file == NULL) ||
> is_failover_file(data, file)) {
> /*
> * Note that nlm_inspect_file updates f_locks
> * and ret is the number of files that can't
> * be unlocked.
> */
> ret += nlm_inspect_file(data, file, match);
> } else
> file->f_locks = nlm_file_inuse(file);

Looks good.

> >>  			mutex_lock(&nlm_file_mutex);
> >>  			file->f_count--;
> >>  			/* No more references to this file. Let go of it. */
> >> -			if (list_empty(&file->f_blocks) && !file->f_locks
> >> +			if (!file->f_locks && list_empty(&file->f_blocks)
> >>     
> >
> > Is this change actually achieving something?  or is it just noise?
> >   
> Not really - but I thought checking for f_locks would be faster (tiny 
> bit of optimization :))

You don't want to put the fastest operation first.  You want the one
that is most likely to fail (as it is an '&&' where failure aborts the
sequence).
So you would need some argument (preferably with measurements) to say
which of the conditions will fail most often, before rearranging as an
optimisation.

NeilBrown
