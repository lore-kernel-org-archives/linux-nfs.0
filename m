From: "Eff Norwood" <enorwood@effrem.com>
Subject: RE: huge number of intr/s on large nfs server
Date: Wed, 16 Oct 2002 13:06:13 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBKELFCFAA.enorwood@effrem.com>
References: <200210151622.07097.habanero@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181uQv-0003mM-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Oct 2002 13:06:21 -0700
To: "Andrew Theurer" <habanero@us.ibm.com>, <nfs@lists.sourceforge.net>
In-Reply-To: <200210151622.07097.habanero@us.ibm.com>
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

> Are you sure you want to use raid5?

Yes. I don't have enough disks to do a mirror/stripe combo and still get the
space I want.

> What mode did you use for ext3?  try data=writeback

For and NFS server, I think that's a bad idea since writeback can allow old
data to show up in files after a crash. I used ordered.

> This can be any module, binary only or not, for kernprof.  It is
> most likely
> your module for the GigE card. Can you check, and if possible,
> build it into
> the kernel?

I can't build the gigabit into the kernel because I need to pass the module
parameters. The rest I can and will build into the kernel.

> Also, make sure you reset the kernel profile after starting the
> test, and stop
> the profile before the test ends.  Otherwise you are getting idle time
> before/after the test.

Got that ok.

> Are you running hyperthreading?  This is a little off topic, but when the
> first problem is fixed, you might want to try hyperthreading.   I
> saw a 25%
> improvement in netbench (samba) on a 2 way P4 Xeon.

No, I'm not. I thought I read on LKML that hyperthreading did nothing except
destabilize the system.

> Also, your local dd test simulated the clients, right?  30 dd's?
Right

> What
> throughput did you get?

About 105-110MB/sec total.

Thanks,

Eff




-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
