From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix NLM reference count panic
Date: Sat, 5 Jan 2008 01:05:09 -0500
Message-ID: <20080105060509.GA29020@fieldses.org>
References: <477EB7D1.9030303@redhat.com> <20080104232422.GF14827@fieldses.org> <477F0F8B.9020706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54182 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751770AbYAEGFM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Jan 2008 01:05:12 -0500
In-Reply-To: <477F0F8B.9020706@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 05, 2008 at 12:03:07AM -0500, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>
>> On Fri, Jan 04, 2008 at 05:48:49PM -0500, Wendy Cheng wrote:
>> This just replaces the file->f_locks check by a search of the inode's
>> lock list.
>>
>> What confuses me here is that the nlm_inspect_file() call just above
>> already did that search, and set file->f_locks accordingly.  The only
>> difference is that now we've acquired the nlm_file_mutex.  I don't
>> understand yet how that makes a difference.
>>
>>  
> You're right. I got the patch sequence wrong. It will cause panic only when 
> we selectively unlock nlm locks under my "unlock" patch as the following. 
> See how it returns without doing nlm_traverse_locks() below ... Let's 
> combine this patch into the big unlock patch so we won't have any 
> confusion. The unlock patch will submitted on Monday after this weekend's 
> sanity check test run. In short, I withdraw this patch... Wendy

OK.  I'll admit to still being a little confused--but with luck it'll
all make sense when I see the whole thing.  Have a good weekend!

--b.

> nlm_inspect_file(struct nlm_host *host, struct nlm_file *file, 
> nlm_host_match_fn_t match)
> {
> + /* Cluster failover has timing constraints. There is a slight
> + * performance hit if nlm_fo_unlock_match() is implemented as
> + * a match fn (since it will be invoked for each block, share,
> + * and lock later when the lists are traversed). Instead, we
> + * add path-matching logic into the following unlikely clause.
> + * If matches, the dummy nlmsvc_fo_match will always return
> + * true.
> + */
> + dprintk("nlm_inspect_files: file=%p\n", file);
> + if (unlikely(match == nlmsvc_fo_match)) {
> + if (!nlmsvc_fo_unlock_match((void *)host, file))
> + return 0;
> + fo_printk("nlm_fo find lock file entry (0x%p)\n", file);
> + }
> +
> nlmsvc_traverse_blocks(host, file, match);
> nlmsvc_traverse_shares(host, file, match);
> return nlm_traverse_locks(host, file, match);
> @@ -369,3 +451,35 @@ nlmsvc_invalidate_all(void)
> */
> nlm_traverse_files(NULL, nlmsvc_is_client);
> }
>
