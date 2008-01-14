From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 15 Jan 2008 10:52:29 +1100
Message-ID: <18315.62909.330258.83038@notabene.brown>
References: <4781BB0D.90706@redhat.com>
	<20080108170220.GA21401@infradead.org>
	<20080108174958.GA25025@infradead.org>
	<4783E3C9.3040803@redhat.com>
	<20080109180214.GA31071@infradead.org>
	<20080110075959.GA9623@infradead.org>
	<4788665B.4020405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: wcheng@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:49860 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751547AbYANXwh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 18:52:37 -0500
In-Reply-To: message from Wendy Cheng on Saturday January 12
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday January 12, wcheng@redhat.com wrote:
> This is a combined patch that has:
> 
> * changes made by Christoph Hellwig
> * code segment that handles f_locks so we would not walk inode->i_flock 
> list twice.
> 
> If agreed, please re-add your "ack-by" and "signed-off" lines 
> respectively. Thanks ...
> 

> -	int i, ret = 0;
> +	int i, ret = 0, inspect_file;
>  
>  	mutex_lock(&nlm_file_mutex);
>  	for (i = 0; i < FILE_NRHASH; i++) {
>  		hlist_for_each_entry_safe(file, pos, next, &nlm_files[i], f_list) {
>  			file->f_count++;
>  			mutex_unlock(&nlm_file_mutex);
> +			inspect_file = 1;
>  
>  			/* Traverse locks, blocks and shares of this file
>  			 * and update file->f_locks count */
> -			if (nlm_inspect_file(host, file, match))
> +
> +			if (unlikely(failover)) {
> +				if (!failover(data, file)) {
> +					inspect_file = 0;
> +					file->f_locks = nlm_file_inuse(file);
> +				}
> +			}
> +
> +			if (inspect_file && nlm_inspect_file(data, file, match))
>  				ret = 1;

if (unlikely(failover) &&
    !failover(data, file))
	file->f_locks = nlm_file_inuse(file);
else if (nlm_inspect_file(data, file, match))
	ret = 1;

Though the logic still isn't very clear... maybe:

if (likely(failover == NULL) ||
    failover(data, file))
	ret |= nlm_inspect_file(data, file, match);
else
    file->f_locks = nlm_file_inuse(file);

Actually I would like to make nlm_inspect_file return 'void'.
The returned value of '1' is ultimately either ignored or it triggers
a BUG().  And the case where it triggers a BUG is the "host != NULL"
case.  (I think - if someone could check, that would be good).
So putting BUG_ON(host) in nlm_traverse_locks (along with a nice big
comment) would mean we can discard the return value from
nlm_traverse_locks and nlm_inspect_file and nlm_traverse_files.

Also, if we could change the function name 'failover' to some sort of
verb like "is_failover" or "is_failover_file", then the above could be

  if (likely(is_failover_file == NULL) ||
      is_failover_file(data, file))
	/* note nlm_inspect_file updates f_locks */
	nlm_inspect_file(data, file, match);
  else
	file->f_locks = nlm_file_inuse(file);


>  
>  			mutex_lock(&nlm_file_mutex);
>  			file->f_count--;
>  			/* No more references to this file. Let go of it. */
> -			if (list_empty(&file->f_blocks) && !file->f_locks
> +			if (!file->f_locks && list_empty(&file->f_blocks)

Is this change actually achieving something?  or is it just noise?


NeilBrown
