From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: fsid question
Date: Tue, 27 Mar 2007 11:23:21 -0400
Message-ID: <20070327152321.GB7161@fieldses.org>
References: <46082D10.1060301@cse.yorku.ca> <46083474.8090906@redhat.com>
	<46091325.6050403@cse.yorku.ca>
	<46091498.6030706@moving-picture.com>
	<46091C41.6070908@cse.yorku.ca> <46092FC2.2080901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: James Pearson <james-p@moving-picture.com>,
	nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWDW7-0006KI-N1
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:23:23 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWDW9-0005BM-D8
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:23:26 -0700
In-Reply-To: <46092FC2.2080901@redhat.com>
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

On Tue, Mar 27, 2007 at 10:52:50AM -0400, Wendy Cheng wrote:
> 1. If server for whatever reason gets rebooted and somehow the device 
> major-minor number gets altered, the client that keeps the "old" file 
> handle will get a "stale file handle" error.

Actually, have you checked this?  From a quick look at

	linux/fs/nfsd/nfsfh.c:fh_verify()
and

	nfs-utils/utils/mountd/cache.c:nfsd_fh()

it looks to me like nfsd should still allow both the old and new
filehandles.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
