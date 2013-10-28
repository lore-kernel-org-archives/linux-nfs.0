Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38407 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756827Ab3J1PJH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 11:09:07 -0400
Date: Mon, 28 Oct 2013 11:08:40 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/8] exportfs: stop retrying once we race with
 rename/remove
Message-ID: <20131028150840.GB3981@pad.fieldses.org>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
 <1382733005-6006-5-git-send-email-bfields@redhat.com>
 <20131027180409.66037e01@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131027180409.66037e01@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 27, 2013 at 06:04:09PM +1100, NeilBrown wrote:
> ... or just open-code it.  Then this becomes:
> 
>   if (!IS_ROOT(find_disconnected_root(target_dir))) {
>          clear_disconnected(target_dir);
>          return 0;
>   }
>   return -ESTALE;
> 
> which is pleasing similar to the (new) code higher up:
> 
> 		struct dentry *pd = find_disconnected_root(target_dir);
> 
> 		if (!IS_ROOT(pd)) {
> 			/* must have found a connected parent - great */
> 			clear_disconnected(target_dir);
>                 ....

We end up ditching the other call to find_disconnected_root(), and I
find dentry_connected() slightly more straightforward here, so I'd
prefer to stick with it as is.

I could do the above as an intermediate step and then write a separate
patch for the !IS_ROOT(find_disconnected_root())->dentry_connected()
that makes that argument explicitly if you think that would be clearer?

Thanks for the review.

--b.
