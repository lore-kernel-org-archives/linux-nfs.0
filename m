From: James Pearson <james-p@moving-picture.com>
Subject: Re: fsid question
Date: Tue, 27 Mar 2007 15:27:06 +0100
Message-ID: <460929BA.9060509@moving-picture.com>
References: <46082D10.1060301@cse.yorku.ca> <46083474.8090906@redhat.com>
	<46091325.6050403@cse.yorku.ca>
	<46091498.6030706@moving-picture.com>
	<46091C41.6070908@cse.yorku.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jason Keltz <jas@cse.yorku.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWCdh-0008Ks-R1
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 07:27:16 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWCdh-0007We-2g
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 07:27:12 -0700
In-Reply-To: <46091C41.6070908@cse.yorku.ca>
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

Jason Keltz wrote:

> Hi James.
> 
> Thanks for your message.
> 
> I'm not sure that I understand this though.  If the system is generating 
> an fsid for NFS exports in the absence of a user-specified fsid, then 
> changing the fsid and re-exporting the filesystem *should* essentially 
> confuse the client? How does one choose an fsid that is not already in 
> use on the system? I imagine there must be some way to list the 
> currently used fsids for exported filesystems.

See the thread starting at:

<http://marc.info/?l=linux-nfs&m=110295083427898&w=2>

James Pearson


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
