From: Neil Brown <neilb@suse.de>
Subject: Re: poor nfs performance & hangs with latest kernels
Date: Tue, 20 Feb 2007 20:45:42 +1100
Message-ID: <17882.49990.799201.335846@notabene.brown>
References: <45D9B915.2010305@hq.vsaa.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Rich <rich@hq.vsaa.lv>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJRa1-0004bT-Fn
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 01:46:37 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HJRa3-0006gP-29
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 01:46:39 -0800
In-Reply-To: message from Rich on Monday February 19
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

On Monday February 19, rich@hq.vsaa.lv wrote:
> hi. i am having a pretty weird nfs performance problems.
> (please, cc me, as i am not on the list).
> 
> when there is some intensive nfs activity (write), all other nfs 
> operations slow down to crawl or even stop at all during that time.
> 
> i have been able to reproduce the problem with kernel versions 
> 2.6.16.40, 2.6.19.2 and 2.6.20 (on  slackware-11.0).
> another person reproduced the hang with 2.6.19-1.2911.fc6 (fedora core 6).

Are there any kernels where you cannot reproduce the problem?

> 
> when the problem appears, access to the same data both locally and even 
> over ssh is happening  without any slowdown, but nfs access is sometimes 
> slowed down significantly, in some cases  even being unable to list a 
> directory for 30 minutes.
> in some cases, not only nfs slowdown happens, but whole system hangs.

So we need to find out exactly what is happening when things slow
down.
Some things that might be useful:
  a tcpdump trace (use -s 0) of traffic which things are going slowly.
  "cat /proc/meminfo /proc/slabinfo".  Get a copy when everything is
     fine, then another few then things are going slowly.
  Maybe "echo t > /proc/sysrq-trigger" and collect the kernel logs.
    If some processes are in 'D' status, this could give useful
    information.

Get the various information on both the server and client if
possible.  Hopefully somewhere in all of that will be a clue.

> there is one scenario where it is very easy to reproduce the problem 
> (note : don't try this on a  remote system or one you can not afford to 
> hard reboot) :
> 
> export a local directory. i'm using 
> localhost(rw,no_root_squash,sync,no_subtree_check).
> mount it locally and try to perform a write operation :
> dd if=/dev/zero of=/mounted_nfs/testfile bs=512k count=2048

This scenario is known to cause problems, is very hard to fix, and is
a case of "well don't do that then".  The problems here are probably
unrelated to the problems you are having between separate machines.

> 
> using 2.6.16.21, i was unable to hang my workstation, but server, even 
> though it survived the test, is still having excessive load (~ 4). top 
> lists as most resource hungry processes nfsd, kjournald and
> kblockd.

So 2.6.16.21 survives but 2.6.16.40 doesn't?  Is that a reliable
result?  Is that with separate server and client, or server and client
on the same machine?

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
