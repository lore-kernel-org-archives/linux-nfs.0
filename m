Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6FD8C43441
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 09:17:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AFCB52081C
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 09:17:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFCB52081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727382AbeK1USM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 15:18:12 -0500
Received: from mga18.intel.com ([134.134.136.126]:34274 "EHLO mga18.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727341AbeK1USM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 15:18:12 -0500
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Nov 2018 01:17:15 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,290,1539673200"; 
   d="scan'208";a="112866993"
Received: from shao2-debian.sh.intel.com (HELO localhost) ([10.239.13.6])
  by orsmga002.jf.intel.com with ESMTP; 28 Nov 2018 01:17:14 -0800
Date:   Wed, 28 Nov 2018 17:17:30 +0800
From:   kernel test robot <rong.a.chen@intel.com>
To:     NeilBrown <neilb@suse.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>, lkp@01.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] locks: fix performance regressions.
Message-ID: <20181128091730.GD21676@shao2-debian>
References: <20181127060102.GF6163@shao2-debian>
 <20181127174315.GA29963@parsley.fieldses.org>
 <87mupup0ot.fsf@notabene.neil.brown.name>
 <87k1kyowdf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87k1kyowdf.fsf@notabene.neil.brown.name>
User-Agent: Mutt/1.10.0 (2018-05-17)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

On Wed, Nov 28, 2018 at 11:53:48AM +1100, NeilBrown wrote:
> 
> The kernel test robot reported two performance regressions
> caused by recent patches.
> Both appear to related to the global spinlock blocked_lock_lock
> being taken more often.
> 
> This patch avoids taking that lock in the cases tested.
> 
> Reported-by: kernel test robot <rong.a.chen@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Hi Jeff,
>  you might like to merge these back into the patches that introduced
>  the problem.
>  Or you might like me to re-send the series with these merged in,
>  in which case, please ask.
> 
>  And a BIG thank-you to the kernel-test-robot team!!
> 
> Thanks,
> NeilBrown
> 
>  fs/locks.c | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index f456cd3d9d50..67519a43e27a 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -444,6 +444,13 @@ static void locks_move_blocks(struct file_lock *new, struct file_lock *fl)
>  {
>  	struct file_lock *f;
>  
> +	/*
> +	 * As ctx->flc_lock is held, new requests cannot be added to
> +	 * ->fl_blocked_requests, so we don't need a lock to check if it
> +	 * is empty.
> +	 */
> +	if (list_empty(&fl->fl_blocked_requests))
> +		return;
>  	spin_lock(&blocked_lock_lock);
>  	list_splice_init(&fl->fl_blocked_requests, &new->fl_blocked_requests);
>  	list_for_each_entry(f, &fl->fl_blocked_requests, fl_blocked_member)
> @@ -749,6 +756,20 @@ int locks_delete_block(struct file_lock *waiter)
>  {
>  	int status = -ENOENT;
>  
> +	/*
> +	 * If fl_blocker is NULL, it won't be set again as this thread
> +	 * "owns" the lock and is the only one that might try to claim
> +	 * the lock.  So it is safe to test fl_blocker locklessly.
> +	 * Also if fl_blocker is NULL, this waiter is not listed on
> +	 * fl_blocked_requests for some lock, so no other request can
> +	 * be added to the list of fl_blocked_requests for this
> +	 * request.  So if fl_blocker is NULL, it is safe to
> +	 * locklessly check if fl_blocked_requests is empty.  If both
> +	 * of these checks succeed, there is no need to take the lock.
> +	 */
> +	if (waiter->fl_blocker == NULL &&
> +	    list_empty(&waiter->fl_blocked_requests))
> +		return status;
>  	spin_lock(&blocked_lock_lock);
>  	if (waiter->fl_blocker)
>  		status = 0;
> -- 
> 2.14.0.rc0.dirty
> 

FYI, the performance recovered back, we didn't find any regression between the two commits.

commit: 
  48a7a13ff3 ("locks: use properly initialized file_lock when unlocking.")
  8f64e497be ("locks: fix performance regressions.")

48a7a13ff31f0728  8f64e497be9929a2d5904c39c4  
----------------  --------------------------  
         %stddev      change         %stddev
             \          |                \  
     33.56 ±  3%         5%      35.30        boot-time.boot
     10497 ±  3%        12%      11733 ±  4%  proc-vmstat.nr_shmem
     67392                       68449        proc-vmstat.nr_zone_active_anon
     67392                       68449        proc-vmstat.nr_active_anon
     16303                       16206        proc-vmstat.nr_slab_reclaimable
     30602                       29921        proc-vmstat.nr_slab_unreclaimable
         0            9e+03       9009 ± 80%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
         0            6e+03       5837 ±139%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
       149 ± 17%      5e+03       5457 ±137%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
       175 ± 29%      4e+03       3807 ±136%  latency_stats.avg.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
     52868 ±110%     -4e+04      17482 ±  4%  latency_stats.avg.max
     45055 ±141%     -5e+04          0        latency_stats.avg.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
       227 ± 10%      1e+04       9907 ±136%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
         0            9e+03       9367 ± 78%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
         0            6e+03       5837 ±139%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
       175 ± 29%      4e+03       3807 ±136%  latency_stats.max.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
     98043 ±124%     -8e+04      20999 ± 27%  latency_stats.max.max
     90059 ±141%     -9e+04          0        latency_stats.max.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1251 ± 23%      5e+04      49005 ±137%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_getattr.__nfs_revalidate_inode.nfs_do_access.nfs_permission.inode_permission.link_path_walk.path_lookupat
         0            1e+04      12061 ± 70%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_do_create.nfs3_proc_create.nfs_create.path_openat.do_filp_open.do_sys_open.do_syscall_64
         0            6e+03       5837 ±139%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.path_openat.do_filp_open.do_sys_open.do_syscall_64.entry_SYSCALL_64_after_hwframe
       175 ± 29%      4e+03       3807 ±136%  latency_stats.sum.rpc_wait_bit_killable.__rpc_execute.rpc_run_task.rpc_call_sync.nfs3_rpc_wrapper.nfs3_proc_lookup.nfs_lookup.__lookup_slow.lookup_slow.walk_component.path_lookupat.filename_lookup
     90111 ±141%     -9e+04          0        latency_stats.sum.io_schedule.nfs_lock_and_join_requests.nfs_updatepage.nfs_write_end.generic_perform_write.nfs_file_write.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe


Best Regards,
Rong Chen
