From: Jehan PROCACCIA <Jehan.Procaccia@int-evry.fr>
Subject: interprtation of /proc/net/rpc/nfsd
Date: Fri, 08 Oct 2004 12:09:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41666777.7030003@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFrhU-0001QS-9q
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 03:10:12 -0700
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CFrhS-0002UH-MI
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 03:10:12 -0700
Received: from [157.159.21.55] (arvouin.int-evry.fr [157.159.21.55])
	by smtp2.int-evry.fr (Postfix) with ESMTP id 9E4BF2FDB2
	for <nfs@lists.sourceforge.net>; Fri,  8 Oct 2004 12:10:58 +0200 (CEST)
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

Hello,

I am tunning my NFS configuration on a RedHat ES v3 (equivalent Fedora 
Core 1 , kernel 2.4.X)  and by reading the docs (NFS howto perf 5.6 )  I 
should see if I have enough NFSD daemon by looking at  
/proc/net/rpc/nfs, especialy line "th"

$ grep th /proc/net/rpc/nfsd
th 8 41598 20357.020 3974.540 1809.300 0.000 998.210 781.650 483.840 
116.640 0.000 825.230

However I cannot understand how to read that information !?
I see that I have 8 threads (8 nfsd daemon runing) but figures after ???

Second question,

How on an NFS client (Here I have fedora core 2 clients) can I see how 
is currently mounted an NFS filsystem, I want to check what are the 
current options in use (nfs version, rsize, wsize, sync/async, hard, 
soft etc ...). On the server I can have a look at /var/lib/nfs/xtab

$ cat /var/lib/nfs/xtab | grep arvouin
/mci/mci        
arvouin.int-evry.fr(rw,async,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,subtree_check,secure_locks,acl,mapping=identity,anonuid=-2,anongid=-2)

but I am often changing options on the server (for tunning purpose) , 
and hence I want to check that my clients is mounted with the latest 
options,  do I need to remount on the client everytime I change options 
on the server ? (exportfs -r -v -a)  ... .checking what is the current 
options on the client would be more clear to me .

thanks.

PS other lines are also not clear in /proc/net/rpc/nfsd
are they clearly explain somewhere ? or is there a better tool to read 
them ?

$ cat /proc/net/rpc/nfsd
rc 77 2279806 4791576
fh 36 7103818 0 107 461
io 2157379507 3834347693
th 8 41598 20368.720 3975.220 1809.300 0.000 998.210 781.650 483.840 
116.640 0.000 825.230
ra 16 316291 228 80 73 25 40 42 17 36 7 22131
net 7071459 56823 7014636 155
rpc 7071459 0 0 0 0
proc2 18 95 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 107 2606933 544561 626398 870018 178 338970 1189408 253948 
14640 200 0 219018 12808 45181 119 0 66482 4981 22 0 277392




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
