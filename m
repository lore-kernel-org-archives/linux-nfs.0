From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 14:43:16 +0100
Message-ID: <200703081443.18604.olaf.kirch@oracle.com>
References: <20070307194418.97fee0ec.simon.peter@gmx.de>
	<17903.19755.146916.321440@notabene.brown>
	<20070308051401.GC15814@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Simon Peter <simon.peter@gmx.de>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	Christoph Hellwig <hch@infradead.org>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPIuf-0003He-KC
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 05:44:09 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPIue-0002qE-9c
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 05:44:11 -0800
In-Reply-To: <20070308051401.GC15814@fieldses.org>
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

On Thursday 08 March 2007 06:14, J. Bruce Fields wrote:
> Maybe.  Is this practical?  Do we know of any cases of users doing this?
> Do you block forever if you try to access 4 filesystems at once?  I
> dunno....

IIRC SGI had a storage appliance a while back that included a tape robot,
but it was hiding the details somewhere deep inside XFS. I remember seeing
patches involving nfsd and dmapi (I can see you cringe, Christoph :-)

Note that in real-life scenarios, we're sometimes talking about literally
thousands of exported file systems. My previous employer has a customer with
such a setup, using NetApp filers. We had some trouble getting the Linux
client to survive in this environment, as it ran out of privileged ports
way too quickly. Absurd as it may sound, this kind of setup seems to be
the trend.

Now think about handling a system with several thousand exported
file systems on the server side - if you need to look at each file system
before nfsd is ready to service requests, we're talking of a considerable
delay in boot time. In the worst case we're talking about several thousand
*disks* that need to be spun up, and fuses going pop-pop-pop.

Short summary - if you want to scale beyond small work group servers,
you need something that scales well. Demand loading the exports
table does.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
