From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: fsid question
Date: Tue, 27 Mar 2007 11:32:01 -0400
Message-ID: <1175009521.6153.18.camel@heimdal.trondhjem.org>
References: <46082D10.1060301@cse.yorku.ca> <46083474.8090906@redhat.com>
	<46091325.6050403@cse.yorku.ca> <46091498.6030706@moving-picture.com>
	<46091C41.6070908@cse.yorku.ca> <46092FC2.2080901@redhat.com>
	<20070327152321.GB7161@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: James Pearson <james-p@moving-picture.com>,
	nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWDep-0007bq-HT
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:32:23 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/npx9bdnMe+pl2hDqaUzlx9SmKRQRPbto=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWDeo-0007SA-3e
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:32:24 -0700
In-Reply-To: <20070327152321.GB7161@fieldses.org>
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

On Tue, 2007-03-27 at 11:23 -0400, J. Bruce Fields wrote:
> On Tue, Mar 27, 2007 at 10:52:50AM -0400, Wendy Cheng wrote:
> > 1. If server for whatever reason gets rebooted and somehow the device 
> > major-minor number gets altered, the client that keeps the "old" file 
> > handle will get a "stale file handle" error.
> 
> Actually, have you checked this?  From a quick look at
> 
> 	linux/fs/nfsd/nfsfh.c:fh_verify()
> and
> 
> 	nfs-utils/utils/mountd/cache.c:nfsd_fh()
> 
> it looks to me like nfsd should still allow both the old and new
> filehandles.

That is correct. A server kernel upgrade should not normally result in a
client error. See also Neil's recently posted patches that replace the
fileid with the disk UUID. Those again attempt to preserve backward
compatibility for filehandles.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
