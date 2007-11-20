From: Gerd Bavendiek <gerd.bavendiek@googlemail.com>
Subject: [NFS] 2.6.5-7.282 or 2.6.5-7.283: kernel: RPC: error 5 or
 nsm_mon_unmon: rpc failed, status=-13
Date: Tue, 20 Nov 2007 18:18:20 +0100
Message-ID: <474316DC.3080502@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuWk6-00069c-D6
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 09:18:34 -0800
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuWkB-0001ux-Rd
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 09:18:40 -0800
Received: by ug-out-1314.google.com with SMTP id m2so1230772uge
	for <nfs@lists.sourceforge.net>; Tue, 20 Nov 2007 09:18:30 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

yes, this is old software from your point of view. But as I could not
get any helpful information so far I would like to ask here.

Running SLES9 SP3 (i.e. 2.6.5-7.244) on many boxes we started to
update some of these systems to 2.6.5-7.282 or 2.6.5-7.283. After this
update we see sometimes errors in the RPC layer.

One example is this box with a very simple setup, nothing special:

ad-test:/root>>> grep -i rpc /var/log/messages
Aug 21 13:42:47 ad-test kernel: RPC: error 5 connecting to server localhost
Aug 21 13:42:47 ad-test kernel: RPC: failed to contact portmap (errno -5).
Aug 21 13:50:51 ad-test kernel: RPC: error 5 connecting to server localhost
Aug 21 13:50:51 ad-test kernel: RPC: failed to contact portmap (errno -5).
Aug 21 14:37:50 ad-test kernel: RPC: error 5 connecting to server localhost
Aug 21 14:37:50 ad-test kernel: RPC: failed to contact portmap (errno -5).
Aug 22 15:11:32 ad-test kernel: RPC: error 5 connecting to server localhost
Aug 22 15:11:32 ad-test kernel: RPC: failed to contact portmap (errno -5).
ad-test:/root>>>

Very interesting: RPC 100024 is missing.

ad-test:/root>>> rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100021    1   udp  32799  nlockmgr
     100021    3   udp  32799  nlockmgr
     100021    4   udp  32799  nlockmgr
     100021    1   tcp  33012  nlockmgr
     100021    3   tcp  33012  nlockmgr
     100021    4   tcp  33012  nlockmgr
ad-test:/root>>>

This is an 2.6.5-7.282, which has been up for 80 days.

Another example, again very simple setup, nothing special:

Aug 15 16:40:22 polyxena kernel: RPC: error 5 connecting to server localhost
Aug 15 16:40:22 polyxena kernel: RPC: failed to contact portmap (errno -5).
Aug 15 16:40:22 polyxena kernel: RPC: error 5 connecting to server localhost
Aug 15 16:40:22 polyxena kernel: RPC: failed to contact portmap (errno -5).

This is an 2.6.5-7.283-smp, uptime 201 days. On this one rpcinfo
output is fine:

polyxena:/root>>> rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp  34281  status
     100021    1   udp  34281  nlockmgr
     100021    3   udp  34281  nlockmgr
     100021    4   udp  34281  nlockmgr
     100024    1   tcp  43627  status
     100021    1   tcp  43627  nlockmgr
     100021    3   tcp  43627  nlockmgr
     100021    4   tcp  43627  nlockmgr
polyxena:/root>>>

We have never seen these errors with 282 or 283 on x86_64. We have never 
seen them with 2.6.5-7.244.

On machines, which boot via pxe and have their root file system on
NetApp filers, we see the above described error _OR_ a second one:

Sep 16 04:46:57 c02ptec kernel: nsm_mon_unmon: rpc failed, status=-13
Sep 16 04:46:57 c02ptec kernel: lockd: cannot unmonitor 10.172.207.7

This may happen 10 minutes after reboot or after 60 days uptime.

Sep 16 04:48:07 c02ptec kernel: nsm_mon_unmon: rpc failed, status=-13
Sep 16 04:48:07 c02ptec kernel: lockd: cannot monitor 10.172.207.7
Sep 16 04:48:07 c02ptec kernel: lockd: failed to monitor 10.172.207.7

Luckily the application still lives, so I have this system still
running:

c02ptec:/var/log>>> uptime
   6:04pm  up 65 days 14:22,  0 users,  load average: 0.06, 0.06, 0.07

despite all NFS kernel threads are gone:

c02ptec:/var/log>>> rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
  100033058    1   tcp  39722
  100033057    1   tcp  39737
c02ptec:/var/log>>>

Are there known issue ?

What can I do to give more information ?

Thanks !

Gerd

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

