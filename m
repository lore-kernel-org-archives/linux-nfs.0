From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH] Fix NLM reference count panic
Date: Sat, 05 Jan 2008 00:03:07 -0500
Message-ID: <477F0F8B.9020706@redhat.com>
References: <477EB7D1.9030303@redhat.com> <20080104232422.GF14827@fieldses.org>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791AbYAEEqI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 23:46:08 -0500
In-Reply-To: <20080104232422.GF14827@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:

>On Fri, Jan 04, 2008 at 05:48:49PM -0500, Wendy Cheng wrote:
>  
>
>>This fixes the incorrect fclose call inside nlm_traverse_files() where 
>>a posix lock could still be held by NFS client. Problem was found in a
>>kernel panic inside locks_remove_flock() (fs/locks.c:2034) as part of 
>>the fclose call due to NFS-NLM locks still hanging on inode->i_flock list. 
>>
>>Also see: http://people.redhat.com/wcheng/Patches/NFS/NLM/001.txt
>>    
>>
>
>Next time it'd be best just to include that into the referred-to text
>into the message.
>  
>

Sorry, forgot to remove it - it was for internal review purpose. I was a 
little bit careless with this patch.

>  
>
>> svcsubs.c |    3 +--
>> 1 files changed, 1 insertion(+), 2 deletions(-)
>>
>>--- gfs2-nmw/fs/lockd/svcsubs.c	2007-04-10 11:59:09.000000000 -0400
>>+++ linux/fs/lockd/svcsubs.c	2007-04-18 10:01:23.000000000 -0400
>>@@ -250,8 +250,7 @@ nlm_traverse_files(struct nlm_host *host
>> 			mutex_lock(&nlm_file_mutex);
>> 			file->f_count--;
>> 			/* No more references to this file. Let go of it. */
>>-			if (list_empty(&file->f_blocks) && !file->f_locks
>>-			 && !file->f_shares && !file->f_count) {
>>+			if (!nlm_file_inuse(file)) {
>> 				hlist_del(&file->f_list);
>> 				nlmsvc_ops->fclose(file->f_file);
>> 				kfree(file);
>>    
>>
>
>This just replaces the file->f_locks check by a search of the inode's
>lock list.
>
>What confuses me here is that the nlm_inspect_file() call just above
>already did that search, and set file->f_locks accordingly.  The only
>difference is that now we've acquired the nlm_file_mutex.  I don't
>understand yet how that makes a difference.
>
>  
>
You're right. I got the patch sequence wrong. It will cause panic only 
when we selectively unlock nlm locks under my "unlock" patch as the 
following. See how it returns without doing nlm_traverse_locks() below 
... Let's combine this patch into the big unlock patch so we won't have 
any confusion. The unlock patch will submitted on Monday after this 
weekend's sanity check test run. In short, I withdraw this patch... Wendy

nlm_inspect_file(struct nlm_host *host, struct nlm_file *file, 
nlm_host_match_fn_t match)
{
+ /* Cluster failover has timing constraints. There is a slight
+ * performance hit if nlm_fo_unlock_match() is implemented as
+ * a match fn (since it will be invoked for each block, share,
+ * and lock later when the lists are traversed). Instead, we
+ * add path-matching logic into the following unlikely clause.
+ * If matches, the dummy nlmsvc_fo_match will always return
+ * true.
+ */
+ dprintk("nlm_inspect_files: file=%p\n", file);
+ if (unlikely(match == nlmsvc_fo_match)) {
+ if (!nlmsvc_fo_unlock_match((void *)host, file))
+ return 0;
+ fo_printk("nlm_fo find lock file entry (0x%p)\n", file);
+ }
+
nlmsvc_traverse_blocks(host, file, match);
nlmsvc_traverse_shares(host, file, match);
return nlm_traverse_locks(host, file, match);
@@ -369,3 +451,35 @@ nlmsvc_invalidate_all(void)
*/
nlm_traverse_files(NULL, nlmsvc_is_client);
}

