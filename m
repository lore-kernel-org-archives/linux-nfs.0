From: Rich <rich@hq.vsaa.lv>
Subject: Re: poor nfs performance & hangs with latest kernels
Date: Tue, 20 Feb 2007 14:45:02 +0200
Message-ID: <45DAED4E.4050504@hq.vsaa.lv>
References: <45D9B915.2010305@hq.vsaa.lv>
	<17882.49990.799201.335846@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJUMt-0000F0-Q2
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 04:45:18 -0800
Received: from [81.198.191.135] (helo=ns1.vsaa.lv)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJUMv-0005Yi-2v
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 04:45:17 -0800
In-Reply-To: <17882.49990.799201.335846@notabene.brown>
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

Neil Brown wrote:
> On Monday February 19, rich@hq.vsaa.lv wrote:
...
>> when there is some intensive nfs activity (write), all other nfs 
>> operations slow down to crawl or even stop at all during that time.
>>
>> i have been able to reproduce the problem with kernel versions 
>> 2.6.16.40, 2.6.19.2 and 2.6.20 (on  slackware-11.0).
>> another person reproduced the hang with 2.6.19-1.2911.fc6 (fedora core 6).
> 
> Are there any kernels where you cannot reproduce the problem?

well, now that my localhost tests are invalidated, i will have to do 
additional testing :)

...
>> export a local directory. i'm using 
>> localhost(rw,no_root_squash,sync,no_subtree_check).
>> mount it locally and try to perform a write operation :
>> dd if=/dev/zero of=/mounted_nfs/testfile bs=512k count=2048
> 
> This scenario is known to cause problems, is very hard to fix, and is
> a case of "well don't do that then".  The problems here are probably
> unrelated to the problems you are having between separate machines.

there i was, hoping to have found a reliable method to reproduce the 
problem...
btw, what's the main cause for this problem ? could it also be observed 
on fast networks or is it limited to cases when server & client are on 
the same machine ?

>> using 2.6.16.21, i was unable to hang my workstation, but server, even 
>> though it survived the test, is still having excessive load (~ 4). top 
>> lists as most resource hungry processes nfsd, kjournald and
>> kblockd.
> 
> So 2.6.16.21 survives but 2.6.16.40 doesn't?  Is that a reliable
> result?  Is that with separate server and client, or server and client
> on the same machine?

most tests were done on a single machine (3 different ones, though), 
after i observed initial problems between several clients and single 
server. so now i will have to redo all the tests with separate client & 
server machines :)

> NeilBrown
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
