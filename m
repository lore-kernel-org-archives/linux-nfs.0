From: Shunichi Sagawa <s-sagawa@jp.fujitsu.com>
Subject: kernel 2.4  The process hang on NFS
Date: Thu, 15 Dec 2005 19:59:25 +0900
Message-ID: <20051215195925.475aee2c.s-sagawa@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmqnP-0005ia-Ev
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 02:57:11 -0800
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EmqnO-0005EQ-69
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 02:57:11 -0800
Received: from m7.gw.fujitsu.co.jp ([10.0.50.77])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id jBFAv2xL016864 for <nfs@lists.sourceforge.net>; Thu, 15 Dec 2005 19:57:02 +0900
        (envelope-from s-sagawa@jp.fujitsu.com)
Received: from s12.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id jBFAv0Wg014626 for <nfs@lists.sourceforge.net>; Thu, 15 Dec 2005 19:57:00 +0900
	(envelope-from s-sagawa@jp.fujitsu.com)
Received: from s12.gw.fujitsu.co.jp (s12 [127.0.0.1])
	by s12.gw.fujitsu.co.jp (Postfix) with ESMTP id 988391CC107
	for <nfs@lists.sourceforge.net>; Thu, 15 Dec 2005 19:57:00 +0900 (JST)
Received: from fjm502.ms.jp.fujitsu.com (fjm502.ms.jp.fujitsu.com [10.56.99.74])
	by s12.gw.fujitsu.co.jp (Postfix) with ESMTP id 562671CC0FE
	for <nfs@lists.sourceforge.net>; Thu, 15 Dec 2005 19:57:00 +0900 (JST)
To: nfs@lists.sourceforge.net
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

Hello, 

In the multithreaded NFS access program,
"Ctrl + C" causes the process hang.

    498 static int
    499 __rpc_execute(struct rpc_task *task)
    500 {
    :
    560                 while (RPC_IS_SLEEPING(task)) {
    561                         /* sync task: sleep here */
    562                         dprintk("RPC: %4d sync task going to sleepn",
    563                                                         task->tk_pid);
    564                         if (current->pid == rpciod_pid)
    565                                 printk(KERN_ERR "RPC: rpciod waiting on sync task!n");
    566 
    567                         __wait_event(task->tk_wait, !RPC_IS_SLEEPING(task));  <= here


Even though a task receives a signal, __wait_event() does not resume the task.
I think that __wait_event_interruptible() should be used instead of __wait_event().

Is it right?

Best Regards,
Sagawa.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
