From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS causing kernel panics
Date: Fri, 30 Apr 2004 16:08:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4092B258.9030304@RedHat.com>
References: <E1BJca7-0004Xp-Jp@sc8-sf-mx1.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJeJk-00036x-O1
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 13:09:04 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BJeJj-0001YG-O2
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 13:09:03 -0700
To: Randy Paries <paries@knology.net>
In-Reply-To: <E1BJca7-0004Xp-Jp@sc8-sf-mx1.sourceforge.net>
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

Randy Paries wrote:  

> I have a machine that is a nfs client. It keeps having kernel panics
>  
> i have included some from the log file
>  
> Both the client and server are very busy
>  
> I am not sure how to debug and i am looking for some direction
> Thanks
> --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
>  
> Apr 30 11:27:47 krusty kernel: nfs: server local.flanders not 
> responding, still trying
> Apr 30 11:27:53 krusty kernel: nfs: server local.flanders OK
> Apr 30 11:35:04 krusty kernel: divide error: 0000
> Apr 30 11:35:04 krusty kernel: autofs nfs lockd sunrpc e100 e1000 
> keybdev mousedev hid input usb-uhci usbcore ext3 jbd raid1 dpt_i2o 
> aic7xxx sd_mod scsi_mod
> Apr 30 11:35:04 krusty kernel: CPU:    0
> Apr 30 11:35:04 krusty kernel: EIP:    0060:[<c012db94>]    Not tainted
> Apr 30 11:35:04 krusty kernel: EFLAGS: 00010246
> Apr 30 11:35:04 krusty kernel:
> Apr 30 11:35:04 krusty kernel: EIP is at schedule_timeout [kernel] 
> 0x64 (2.4.20-31.9smp)
> Apr 30 11:35:04 krusty kernel: eax: 00000000   ebx: 000299af   ecx: 
> f1408b80   edx: 00000000
> Apr 30 11:35:04 krusty kernel: esi: e8273f1c   edi: 00000000   ebp: 
> 00000000   esp: e8273f10
> Apr 30 11:35:04 krusty kernel: ds: 0068   es: 0068   ss: 0068
> Apr 30 11:35:04 krusty kernel: Process httpd (pid: 4397, 
> stackpage=e8273000)
> Apr 30 11:35:04 krusty kernel: Stack: e8273f1c c02080fc 00000000 
> e8e7f968 e8de3f1c 000299af e8272000 c012db20
> Apr 30 11:35:04 krusty kernel:        e8273fa8 00000000 bfffe7c0 
> 00000000 bfffe7c0 c0166ba6 00000001 eb554000
> Apr 30 11:35:04 krusty kernel:        e8273f60 e8273f64 e8272000 
> e8272000 00000000 00000000 000005dd bfffe7c0
> Apr 30 11:35:04 krusty kernel: Call Trace:   [<c02080fc>] sock_poll 
> [kernel] 0x2c (0xe8273f14))
> Apr 30 11:35:04 krusty kernel: [<c012db20>] process_timeout [kernel] 
> 0x0 (0xe8273f2c))
> Apr 30 11:35:04 krusty kernel: [<c0166ba6>] do_pollfd [kernel] 0x166 
> (0xe8273f44))
> Apr 30 11:35:04 krusty kernel: [<c0166d7b>] sys_poll [kernel] 0x17b 
> (0xe8273f78))
> Apr 30 11:35:04 krusty kernel: [<c01098cf>] system_call [kernel] 0x33 
> (0xe8273fc0))
> Apr 30 11:35:04 krusty kernel:
> Apr 30 11:35:04 krusty kernel:
> Apr 30 11:35:04 krusty kernel: Code: f7 ff ff a1 64 a9 3f c0 29 c6 31 
> c0 85 f6 8b 5c 24 2c 0f 49
> Apr 30 12:07:24 krusty syslogd 1.4.1: restart.
> Apr 30 12:07:24 krusty syslog: syslogd startup succeeded
> Apr 30 12:07:24 krusty kernel: klogd 1.4.1, log source = /proc/kmsg 
> started.
> Apr 30 12:07:24 krusty kernel: Linux version 2.4.20-31.9smp 
> (bhcompile@daffy.perf.redhat.com 
> <mailto:bhcompile@daffy.perf.redhat.com>) (gcc version 3.2.2 20030222 
> (Red Hat Linux 3.2.2-5)) #1 SMP Tue Apr 13 17:40:10 EDT 2004
> A

Its not clear to me why you think this is an NFS problem.... It looks to me
that is some type of Floating point exception (i.e divide error: 0000) in
either the scheduling or network code...

SteveD.




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
