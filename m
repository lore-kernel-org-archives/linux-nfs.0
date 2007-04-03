From: =?GB2312?B?wfXUwA==?= <liuyue@ncic.ac.cn>
Subject: ClientBeingBlockedbyAnotherClient
Date: Tue, 03 Apr 2007 16:37:17 +0800
Message-ID: <4612123D.1060107@ncic.ac.cn>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0138578148=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYeVv-0007zE-EJ
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 01:37:15 -0700
Received: from gatekeeper.ncic.ac.cn ([159.226.41.188] helo=ncic.ac.cn)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HYeVv-00078L-IN
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 01:37:17 -0700
Received: from [10.10.11.252] (trumpet.ncic.ac.cn [159.226.41.129])
	(Authenticated sender: liuyue)
	by ncic.ac.cn (Postfix) with ESMTP id A3D37FB046
	for <nfs@lists.sourceforge.net>; Tue,  3 Apr 2007 16:37:14 +0800 (CST)
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

--===============0138578148==
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit

Hello,

I have met with a problem while using NFS.

First I will describe my deployment:

One Server:

On node1
Version 3
/etc/exports/:
/mnt/test *(rw,async,no_root_squash)

Two Clients:

Client1:
On node1(together with the NFS server)
mount options:
mount node1:/mnt/test /mnt/nfs

Client2:
On node2
mount options:
mount node1:/mnt/test /mnt/nfs

Then, I launch iozones on both client1 and client2 simultaneously.
node1:#./iozone -s 1g -r 1m -i 0 -f /mnt/nfs/file -c -e -+n -t 8
node2:#./iozone -s 1g -r 1m -i 0 -f /mnt/nfs/file2 -c -e -+n -t 8

I watch the files' sizes by erupting ll /mnt/nfs repeatly, I will find
that the iozone on Client1 will be blocked by Client2, since the size of
/mnt/nfs/file will not increasing until /mnt/nfs/file2's size has grown
to 1g. I have tried many times, and got the same results.

It seems I have got the reason:
On node1 both iozone and nfsd will get stuck in balance_dirty_pages()
circulation under heavy writeout loads. They will not come out until the
amount of dirty+writeback+unstable memory is below dirty_ratio. But
nfsd's dirty_ratio is 1/4 larger than iozone's dirty_ratio, since nfsd's
process flag has been set PF_LESS_THROTTLE. So nfsd will come out of the
circulaton easily. But nfsd will produce new local filesystem dirty
pages(serving client2's NFS dirty pages) while writing out some of them.
So the amount of dirty+writeback+unstable memory keep in the range
between iozone's dirty_ratio and nfsd's dirty_ratio(that is larger than
iozone's dirty ratio and smaller than nfsd's dirty_ratio). Once the
occassion is like this, iozone will never come out of the
balance_dirty_pages() circulatioin until iozone on client2 terminates.

I know PF_LESS_THROTTLE is introduced to solve the NFS mount of
localhost problem. But does anyone have some ideas to solve my problem ?

Any idea will be appreciated.

Thanks!


ganzi





--===============0138578148==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0138578148==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0138578148==--
