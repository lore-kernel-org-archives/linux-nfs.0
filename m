From: Olaf Kirch <okir@suse.de>
Subject: Processes stuck in D state
Date: Wed, 18 Feb 2004 17:33:05 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040218163305.GA31893@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="/9DWx/yDrRhgMJTb"
Cc: Olaf Hering <olh@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtUi8-00036s-L5
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 08:38:08 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AtUW7-0005lE-8i
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 08:25:43 -0800
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	by Cantor.suse.de (Postfix) with ESMTP id 08D801FA5DA
	for <nfs@lists.sourceforge.net>; Wed, 18 Feb 2004 17:33:06 +0100 (CET)
To: nfs@lists.sourceforge.net
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


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline


Hi,

I spent much of today investigating a weird NFS problem on 2.6.3.

After one of our servers went away and came back, several processes on
a ppc machine were left in D state. They did not get woken up during
the whole day, until I did a "umount -f" after several hours of debugging.

The internal state of this RPC client looks a little weird. I'm
attaching some debug output that shows where they got stuck. Some
general observation:

 -	this does not seem a queue corruption bug, which is good :)
 -	the tasks were sleeping on different wait queues (pending,
 	sending, 1 one resend)
 -	all tasks have a tk_timeout value of 0
 -	the ntimeo values of the RTT estimators being 0 looks a
	little weird, given that the mount froze because the
	server wasn't reachable.
 -	the task on the resend queue has a timer with
	tk_timer.expires != 0, but unfortunately I forgot to check whether
	it was active.	But I doubt it; I had debugging enabled for much
	of the day and the tk_pid in question never showed up in the log

I'm not sure yet what exactly happened here. I don't understand how a
task on xprt->pending can have a timeout value of 0...

Does anyone have an idea what might be going wrong here?

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=nfs-messages

 Found NFS mount, server=Hilbert2,v3,rsize=8192,wsize=8192
   RPC client 6 users
     Active RPC tasks for this client:
       task 21384, status=-11, timeout=0, active, sleeping, on queue c45ea044(xprt_sending)
       task 9969, status=-11, timeout=0, active, sleeping, on queue c45ea044(xprt_sending)
       task 52431, status=-11, timeout=0, active, sleeping, on queue c45ea044(xprt_sending)
       task 43528, status=-11, timeout=0, active, sleeping, on queue c45ea044(xprt_sending)
       task 43527, status=-11, timeout=0, timer, async, active, sleeping, on queue c45ea050(xprt_resend)
       task 55816, status=0, timeout=0, active, sleeping, on queue c45ea05c(xprt_pending)
     Transport c45ea000, sockstate=0x1
       cong 256/cwnd 256
       RTT estimates (def timeout 700):
         0: rtt   15 srtt  100 ntimeo   0
         1: rtt   15 srtt  100 ntimeo   0
         2: rtt   49 srtt  100 ntimeo   0
         3: rtt   15 srtt  100 ntimeo   0
         4: rtt   15 srtt  100 ntimeo   0
     RPC wait queue sending:
       task 43528, status=-11, timeout=0, active, sleeping
       task 52431, status=-11, timeout=0, active, sleeping
       task 9969, status=-11, timeout=0, active, sleeping
       task 21384, status=-11, timeout=0, active, sleeping
     RPC wait queue pending:
       task 55816, status=0, timeout=0, active, sleeping
     RPC wait queue resend:
       task 43527, status=-11, timeout=0, active timer, async, active, sleeping
     RPC wait queue backlog: empty

--/9DWx/yDrRhgMJTb--


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
