From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS export of TMPFS
Date: Fri, 01 Dec 2006 16:58:47 -0500
Message-ID: <4570A597.2070106@redhat.com>
References: <4570A2C1.3060707@ornl.gov> <4570A407.6020007@redhat.com>
	<4570A51B.3080800@ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GqGP9-0004uW-Il
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 13:58:47 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GqGPA-0007la-Q4
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 13:58:49 -0800
To: Weikuan Yu <wyu@ornl.gov>
In-Reply-To: <4570A51B.3080800@ornl.gov>
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

Weikuan Yu wrote:
> Thansk for your prompt reply. Forgot to add that they are exported. 
> Here  is the output from exportfs. The problem is I can nfs-mount 
> /data (/dev/hda2) fine, but not /nfs (tmpfs). 

Sorry, just a little cautious from the snippet of commands -- you
exported /nfs _after_ it was created/mounted?  That wasn't shown
in the list of commands...

    Thanx...

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
