From: Steve Dickson <SteveD@redhat.com>
Subject: Re: RHEL3 Update 1 and NetApp NFS freeze issues
Date: Fri, 10 Sep 2004 07:12:12 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41418C0C.1030405@RedHat.com>
References: <5D5AD1BFE69EDE4283AE056291B89499074861ED@ca00exh03.ca.atitech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5jNe-0007Fy-II
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 04:15:52 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C5jNQ-0002Xv-TV
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 04:15:40 -0700
To: John Nitis <jnitis@ati.com>
In-Reply-To: <5D5AD1BFE69EDE4283AE056291B89499074861ED@ca00exh03.ca.atitech.com>
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

John Nitis wrote:

>Greetings,
>
>This is a bit of a stab in the dark but I thought this might be a good forum
>to ask for input as it has both Linux NFS experts and a NetApp expert who
>are regular contributors.  We are unsure what the cause of the problem is
>(even whether it's hardware or software) but one of our focuses is NFS
>hangs.
>
>Our problem is this, essentially we have an entire rack of machines (57 of
>them) that lock up on a very regular basis.  They respond to ping but do not
>respond to telnet, ssh, etc.  When you plug in a VGA monitor/PS2 keyboard
>the screen pops up but you can't login.  When you hit enter it just echoes
>back a linefeed on the screen.  A small percentage of them kernel panic
>
Set up netdump so wen an oops occurs, a system image (or core) will be
created. Then use the crash to examine the the core. This will give you
a wealth of information on what is going on in the system.
(Note: You'll have to install the correct kernel-debuginfo for this to 
work).

When the system just hangs, make sure the Alt-SysRq  keys are  enabled
(by doing a "echo 1 > /proc/sys/kernel/sysrq"). Then use:
Alt-SysRq-p  to see where the process(es) are doing
Alt-SysRq T to get  system stack
Alt-SysRq M to memory information

>We have "top" and "ps augxww" output logging to a file once per minute and
>some of them show excessive load averages before they freeze with many
>processes stuck in D (uninterruptible sleep or disk wait).  If you catch
>these before the load average gets too high you can tell that a mount has
>locked up (df hangs after displaying a few mounts and you can't access the
>mount that's locked up).  Each new process that gets stuck adds 1 to the
>load average.  The machine locks up in exactly the same way when we yank the
>Ethernet cable from the box.
>  
>
Before things go south, does ifconfig ethX show any interface errors?

>Does anyone have any ideas as to what might be the problem or how we might
>go about debugging it further?  I've recently set the debugging levels to
>"10" in /proc/sys/sunrpc/rpc_debug and /proc/sys/sunrpc/nfs_debug to see if
>that will garner some information.  A few details follow below.
>
>  
>
If your using autofs/amd (if you can) turn it off to see what happens.

I hope this helps....

SteveD.



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
