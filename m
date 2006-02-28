From: Olivier Croquette <ocroquette@free.fr>
Subject: NFS client hangs under certain circumstances on SMP machine
Date: Tue, 28 Feb 2006 21:35:40 +0100
Message-ID: <4404B41C.10404@free.fr>
Reply-To: ocroquette@free.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FEBZo-0007mV-Qm
	for nfs@lists.sourceforge.net; Tue, 28 Feb 2006 12:36:09 -0800
Received: from moutng.kundenserver.de ([212.227.126.177])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FEBZm-0000nq-6X
	for nfs@lists.sourceforge.net; Tue, 28 Feb 2006 12:36:08 -0800
To: LKML <linux-kernel@vger.kernel.org>
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

Hi

I have already sent this message on the NFS mailing-list, but I had no 
reaction there. May be you kernel hackers have an idea?



I have a strange problem since a few months on some Linux clients.

I have a file server accessed through:
   - NFS from Linux clients (autofs, but direct mount causes same effect)
   - Samba from Windows clients

This works since several years like a charm, but as I said there is a
strange problem that appeared recently:

I have a directory, to which I generate code from Windows (\\server\dir)
I can see it under Linux (/mount/dir) where I can access (compile) the
files.

However, when I regenerate the file under Windows again (ie. I overwrite
the old files), and I try to compile the files again under Linux, "make"
hangs simply in D state:

# ps aux | grep make
user 7177 0.0  0.0 1984 760 pts/1 D+ 16:13 0:00 make -f myMakefile

The load average goes up one unit each time I reproduce this test 
(apparently, processes in non-interruptible state are considered as 
running).

 From then, the following actions does NOT unblock the process:
   - stopping or restarting the NFS service on the server
   - restarting the server
   - restarting autofs on the client
   - trying to unmount the NFS mount

If I reboot the client, all goes back to normal, until I repeat the
process below (ie. overwriting and compiling).
Typically, "shutdown -r" does not work, I have to "reboot -f".

There is nothing interesting in /var/log on the server nor on the
client.

Versions used on the server:
   - SuSE 9.3
   - kernel-default-2.6.11.4-21.11
   - nfs-utils-1.0.7-3
   - samba-3.0.13-1.1
   - filesystem: reiserfs

On the client:
   - SuSE 9.3
   - kernel-smp-2.6.11.4-21.10
   - nfs-utils-1.0.7-3
   - mounts:
     automount on /mount type autofs 
(rw,fd=4,pgrp=6529,minproto=2,maxproto=4)
     serv:/dir on /mount/dir type nfs (rw,addr=*IP*)
   - CPU: P4 with hyper threading (2 virtual CPUs)
Note: maxcpus=0 does not make any difference regarding this issue. I
could not test yet with kernel compiled without SMP at all.


On the following clients with the very same server, network, and mount 
tables I could not reproduce the problem:

   - SuSE 9.1
   - kernel-default-2.6.5-7.202.7
   - nfs-utils-1.0.6-103
   - CPU: P4 single core

   - SuSE 10.0
   - Kernel: 2.6.14.3-default (from kernel.org)
   - nfs-utils-1.0.7-13


Any idea?
Seems to me as it is related to the SMP. What do you think?
How can I debug further?




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
