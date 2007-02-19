From: Rich <rich@hq.vsaa.lv>
Subject: poor nfs performance & hangs with latest kernels
Date: Mon, 19 Feb 2007 16:49:57 +0200
Message-ID: <45D9B915.2010305@hq.vsaa.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJ9qF-0007cC-Mx
	for nfs@lists.sourceforge.net; Mon, 19 Feb 2007 06:50:11 -0800
Received: from [81.198.191.135] (helo=ns1.vsaa.lv)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJ9qF-0002DT-Hh
	for nfs@lists.sourceforge.net; Mon, 19 Feb 2007 06:50:13 -0800
Received: from hq.vsaa.lv (tvertne.vsaa.lv [10.196.1.66])
	by ns1.vsaa.lv (8.13.1/8.13.1) with ESMTP id l1JEnwZU021515
	for <nfs@lists.sourceforge.net>; Mon, 19 Feb 2007 16:49:59 +0200
Received: from localhost (localhost [127.0.0.1])
	by hq.vsaa.lv (Postfix) with ESMTP id 9CAF715B561
	for <nfs@lists.sourceforge.net>; Mon, 19 Feb 2007 16:49:58 +0200 (EET)
Received: from hq.vsaa.lv ([127.0.0.1])
	by localhost (hq.vsaa.lv [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id V4BcFympzxI4 for <nfs@lists.sourceforge.net>;
	Mon, 19 Feb 2007 16:49:57 +0200 (EET)
Received: from [10.196.5.213] (unknown [10.196.5.213])
	by hq.vsaa.lv (Postfix) with ESMTP id 5ABF715B560
	for <nfs@lists.sourceforge.net>; Mon, 19 Feb 2007 16:49:57 +0200 (EET)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

hi. i am having a pretty weird nfs performance problems.
(please, cc me, as i am not on the list).

when there is some intensive nfs activity (write), all other nfs 
operations slow down to crawl or even stop at all during that time.

i have been able to reproduce the problem with kernel versions 
2.6.16.40, 2.6.19.2 and 2.6.20 (on  slackware-11.0).
another person reproduced the hang with 2.6.19-1.2911.fc6 (fedora core 6).

when the problem appears, access to the same data both locally and even 
over ssh is happening  without any slowdown, but nfs access is sometimes 
slowed down significantly, in some cases  even being unable to list a 
directory for 30 minutes.
in some cases, not only nfs slowdown happens, but whole system hangs.

i have tried nfstools 1.0.10 and 1.0.7 & portmap 5.0 (though their 
versions seem to have no impact).

there is one scenario where it is very easy to reproduce the problem 
(note : don't try this on a  remote system or one you can not afford to 
hard reboot) :

export a local directory. i'm using 
localhost(rw,no_root_squash,sync,no_subtree_check).
mount it locally and try to perform a write operation :
dd if=/dev/zero of=/mounted_nfs/testfile bs=512k count=2048

depending on machine, i jave managed to get from 32mb (my workstation) 
to ~ 880mb (server) files. then, either nfs becomes unaccessible (for 
all hosts and all disks/exported filesystems), or machine hangs 
completely. if machine does not hang, it's load increases steadily, and 
all cpus are shown to have very high iowait load.

using 2.6.16.21, i was unable to hang my workstation, but server, even 
though it survived the test, is still having excessive load (~ 4). top 
lists as most resource hungry processes nfsd, kjournald and
kblockd.
in this case, stopping nfs server seems to lower the load and return the 
system to normal state.

this seems to be very similar to already reported bug, 
http://bugme.osdl.org/show_bug.cgi?id=7943

has anybody else seen such a behaviour ?
i would appreciate if somebody could test this or provide additional 
things to test. flips on #linux-nfs noted that "it would be good to get 
a sysrq-t listing". if required, i could try this on my workstation with 
either 16.21, 19.1 or .20 - though, if really needed, probably with any 
kernel version :)
in such a case i would be glad to receive some guidance how to best 
perform this activity and gather output.
thanks.
-- 
  Rich

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
