From: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
Subject: nfsd: terminating on error 104 problem
Date: Thu, 04 Mar 2004 10:41:02 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <404707BE.9070401@framestore-cfc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyqOR-0002FO-Si
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 02:47:55 -0800
Received: from gw.fs-cfc.co.uk ([193.203.83.22])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1Aypz1-0007Nw-IX
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 02:21:39 -0800
Received: from localhost (localhost [127.0.0.1])
	by mail.admin.local (Postfix) with ESMTP id 4BAFD7153B4
	for <nfs@lists.sourceforge.net>; Thu,  4 Mar 2004 10:41:05 +0000 (GMT)
Received: from framestore-cfc.com (sys33.prod.local [172.18.10.33])
	by mail.admin.local (Postfix) with ESMTP id 65D4670FF82
	for <nfs@lists.sourceforge.net>; Thu,  4 Mar 2004 10:41:02 +0000 (GMT)
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

Hi all

We are currently using quite a number of HP DL380 servers within our 
company that use the 2.4.25 kernel. These are primarily used for heavy 
NFS access, so we keep a large number of nfsd processes concurrently 
running. We have noticed over time however that single instances of nfsd 
processes periodically die. From inspection of the system logs, we get 
numerous entries:

Feb 22 12:25:24 ps29 kernel: nfsd: recvfrom returned errno 104
Feb 22 12:25:24 ps29 kernel: nfsd: terminating on error 104

At the moment we cron a script that counts the number of nfsds and 
restart rpc.nfsd if they drop below a threshold. Although this is a 
working solution, it's not ideal and we would really like to get his 
problem patched up properly.

So from my limited knowledge of the kernel source I can see that 
"terminating on error 104" corresponds to line 221 of
/usr/src/linux-2.4.25/fs/nfsd/nfssvc.c. So svc_recv on line 191 is 
obviously returning -104.

I've noticed that in the 2.6 kernel there are quite a few changes to 
nfssvc.c, and I wondered if they dealt with this situation.

In the mean time, are there any quick hacks I could add to nfssvc.c to 
make it tolerate error -104? Could I safely alter the main request loop 
to simply continue execution if svc_recv returns this code?

Any help would be much appreciated.

Many thanks,

-- 
Johan van den Dorpe


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
