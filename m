From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: Fri, 09 May 2003 10:12:27 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EBBB74B.4000008@RedHat.com>
References: <482A3FA0050D21419C269D13989C6113127DB3@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19E8bd-0007ub-00
	for <nfs@lists.sourceforge.net>; Fri, 09 May 2003 07:12:13 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

It has to do with the value of HZ.... On a ia64, HZ is
at 1024 and on an x86 machine its 100. Not taking this
difference in account when figure the the minimal
timeout values was causing timeouts to occur every 4ms
instead of 40ms.

The network trace didn't show anything substantial,
but here is the debugging trail.

By logging (and counting) the number of times call_status() was called
with a -ETIMEDOUT status, it became very apparent that ia64 machine
were timing out thousands of times more often than an x86 machine.
The actual numbers was something like 1400 to 50 when I generated
traffic by doing  md5sum /nfs/mounted/*.rpm > /dev/null.

Next I took a look at what task->tk_timeout was being set to in
do_xprt_transmit(). On an x86 it was being set to ~40ms. On
an ia64 machine it was being set to ~4ms.

That lead me to how rpc_calc_rto() was figuring out
the RTOs... I noticed that RPC_RTO_MIN was the only
constant that was not relative to HZ. So I did some
experiments and found out by making it relative to HZ
the timeout decreased substantially...

SteveD.

Lever, Charles wrote:

>steve-
> 
>can you explain why there are more timeouts for ia64?  do you
>have a network trace you can share?
>
>-----Original Message----- 
>From: Steve Dickson [mailto:SteveD@RedHat.com] 
>Sent: Fri 5/9/2003 8:41 AM 
>To: nfs@lists.sourceforge.net 
>Cc: 
>Subject: [NFS] [PATCH] Timeouts gone wild on ia64
>
>
>
>Here is a patch that greatly reduces that number of 
>timeout (and EIO errors with soft mounts) that 
>occur when a fast client is talking to a slow server. 
>  
>We were noticing a large number of EIO errors when 
>a ia64 client was talking to a x86 server with 
>soft mounts (ala autofs).... 
>
>True, EIO errors should be expect with soft mounts but 
>it turns out that thousands of timeouts were occurring on 
>a ia64 client compared to 50 to 60 timeouts with 
>a x86 client when talking to the same slow server and 
>generating the same traffic. 
>
>What this patch does is make the minimal Round Trip 
>time value relative to HZ. So When HZ is greater (as 
>in the case of ia64) the minimal value goes up. 
>  
>Comments? 
>
>SteveD. 
>
>  
>




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
