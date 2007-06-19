From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Usermodehelper vs NFS Client Deadlock
Date: Tue, 19 Jun 2007 07:51:20 -0400
Message-ID: <20070619075120.393fdf83.jlayton@redhat.com>
References: <200706141348.42119.behlendorf1@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: behlendorf1@llnl.gov
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I0cF2-0001lP-TW
	for nfs@lists.sourceforge.net; Tue, 19 Jun 2007 04:51:25 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I0cF5-0006y3-V2
	for nfs@lists.sourceforge.net; Tue, 19 Jun 2007 04:51:28 -0700
In-Reply-To: <200706141348.42119.behlendorf1@llnl.gov>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 14 Jun 2007 13:48:41 -0700
Brian Behlendorf <behlendorf1@llnl.gov> wrote:

> 
> Recently I've observed some interesting NFS client hangs here at LLNL.  I
> dug in to the issue and resolved it but I thought it was also a good idea
> to post the patch back upstream for further refinement and review.
> 
> The root cause of the NFS hang we were observing appears to be a rare
> deadlock between the kernel provided usermodehelper API and the linux NFS
> client.  The deadlock can arise because both of these services use the generic 
> linux work queues. 

Are you sure this is correct? From my look at this, it looks like the
usermodehelper stuff uses its own workqueue (khelper). It looks like earlier
versions of the usermodehelper stuff might have used keventd, but it looks
like it's had its own kthread for several years now.

> The usermodehelper API run the specified user application 
> in the context of the work queue.  And NFS submits both cleanup and reconnect 
> work to the generic work queue for handling.  Normally this is fine but a 
> deadlock can result in the following situation.
> 
>   - NFS client is in a disconnected state
>   - [events/0] runs a usermodehelper app with an NFS dependent operation,
>     this triggers an NFS reconnect.
>   - NFS reconnect happens to be submitted to [events/0] work queue.
>   - Deadlock, the [events/0] work queue will never process the reconnect
>     because it is blocked on the previous NFS dependent operation which 
>     will not complete.
> 
> The correct solution it seems to me is for NFS not to use the generic
> work queues.  A dedicated NFS work queue should be created because the NFS
> client will never have a guarantee that there are no NFS dependent 
> operations in the generic work queues.
> 
> The attached patch implements this by adding a per-protocol work queue
> for the NFS related work items.  One work queue for all NFS client work
> items would be better but that would have required a little more churn to
> the existing code base.  That said this patch is working well for us.
> 
> Thanks,
> Brian
> 
> 
> --------- Stacks from deadlocked system ------------
> 
> PID: 12401  TASK: 10044576330       CPU: 2   COMMAND: "khelper"
>  #0 [1009dd71548] schedule at ffffffff802f0cab
>  #1 [1009dd71620] flush_cpu_workqueue at ffffffff80144329
>  #2 [1009dd716c0] flush_workqueue at ffffffff801443c4
>  #3 [1009dd716e0] __rpc_execute at ffffffffa0028ee7
>  #4 [1009dd71770] rpc_call_sync at ffffffffa002479c
>  #5 [1009dd717a0] nfs3_rpc_wrapper at ffffffffa0074c87
>  #6 [1009dd717d0] nfs3_proc_getattr at ffffffffa0074edf
>  #7 [1009dd71830] __nfs_revalidate_inode at ffffffffa006be91
>  #8 [1009dd71940] nfs_lookup_revalidate at ffffffffa006764b
>  #9 [1009dd71af0] do_lookup at ffffffff80184fd4
> #10 [1009dd71b30] __link_path_walk at ffffffff8018556f
> #11 [1009dd71bf0] link_path_walk at ffffffff80186270
> #12 [1009dd71cd0] path_lookup at ffffffff801864c0
> #13 [1009dd71d00] open_exec at ffffffff80181afa
> #14 [1009dd71df0] do_execve at ffffffff80182e5f
> #15 [1009dd71e30] sys_execve at ffffffff8010de46
> #16 [1009dd71e60] execve at ffffffff8011004d
> #17 [1009dd71f10] ____exec_usermodehelper at ffffffff80143994
> #18 [1009dd71f40] ____call_usermodehelper at ffffffff801439d4
> #19 [1009dd71f50] kernel_thread at ffffffff8010ffdf
> 
> PID: 12     TASK: 1012aa2a130       CPU: 2   COMMAND: "events/2"
>  #0 [1012aa33b18] schedule at ffffffff802f0cab
>  #1 [1012aa33bf0] wait_for_completion at ffffffff802f0eef
>  #2 [1012aa33c70] call_usermodehelper at ffffffff80143b97
>  #3 [1012aa33d50] libcfs_run_upcall at ffffffffa01d8726
>  #4 [1012aa33d90] kpr_do_upcall at ffffffffa0206a5f
>  #5 [1012aa33e70] worker_thread at ffffffff80144136
>  #6 [1012aa33f20] kthread at ffffffff80147e5b
>  #7 [1012aa33f50] kernel_thread at ffffffff8010ffdf
> 


-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
