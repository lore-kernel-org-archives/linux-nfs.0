From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: kernel 2.4  The process hang on NFS
Date: Thu, 15 Dec 2005 09:10:45 -0500
Message-ID: <1134655845.7954.4.camel@lade.trondhjem.org>
References: <20051215195925.475aee2c.s-sagawa@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmtpB-0001RN-3P
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 06:11:13 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emtp8-0003M3-Am
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 06:11:13 -0800
To: Shunichi Sagawa <s-sagawa@jp.fujitsu.com>
In-Reply-To: <20051215195925.475aee2c.s-sagawa@jp.fujitsu.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, 2005-12-15 at 19:59 +0900, Shunichi Sagawa wrote:
> Hello, 
> 
> In the multithreaded NFS access program,
> "Ctrl + C" causes the process hang.
> 
>     498 static int
>     499 __rpc_execute(struct rpc_task *task)
>     500 {
>     :
>     560                 while (RPC_IS_SLEEPING(task)) {
>     561                         /* sync task: sleep here */
>     562                         dprintk("RPC: %4d sync task going to sleepn",
>     563                                                         task->tk_pid);
>     564                         if (current->pid == rpciod_pid)
>     565                                 printk(KERN_ERR "RPC: rpciod waiting on sync task!n");
>     566 
>     567                         __wait_event(task->tk_wait, !RPC_IS_SLEEPING(task));  <= here
> 
> 
> Even though a task receives a signal, __wait_event() does not resume the task.
> I think that __wait_event_interruptible() should be used instead of __wait_event().
> 
> Is it right?

Yes. See the 2.6 kernels, which have fixed this.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
