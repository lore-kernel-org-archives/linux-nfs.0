From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: fsid question
Date: Tue, 27 Mar 2007 11:05:47 -0400
Message-ID: <20070327150547.GA7161@fieldses.org>
References: <46082D10.1060301@cse.yorku.ca> <46083474.8090906@redhat.com>
	<46091325.6050403@cse.yorku.ca>
	<46091498.6030706@moving-picture.com>
	<46091C41.6070908@cse.yorku.ca>
	<460929BA.9060509@moving-picture.com> <460930DE.50507@cse.yorku.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: James Pearson <james-p@moving-picture.com>,
	nfs@lists.sourceforge.net
To: Jason Keltz <jas@cse.yorku.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWDF9-0003uM-T0
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:05:54 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HWDFA-0001RQ-IY
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:05:54 -0700
In-Reply-To: <460930DE.50507@cse.yorku.ca>
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

On Tue, Mar 27, 2007 at 10:57:34AM -0400, Jason Keltz wrote:
> That makes sense, but what is still not clear to me is why I can't have 
> the system show me the existing fsid that it is using in the absence of 
> a user-specified fsid.

There *is* no "existing fsid".  The fsid that you provide in the "fsid="
export option is totally different from what's used by default to
generate filehandles for that filesystem.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
