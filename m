From: "Christian G. Warden" <cwarden@xerus.org>
Subject: Re: nfs3/krb5 mounts fail
Date: Thu, 14 Dec 2006 15:04:47 -0800
Message-ID: <20061214230447.GI21890@xerus.org>
References: <20061211185547.GD25219@xerus.org>
	<4d569c330612120920g3d36cfe6j8baaf3054fec6ac3@mail.gmail.com>
	<20061212233813.GD21890@xerus.org>
	<4d569c330612121807x6a37db7av427cec506dd0b15b@mail.gmail.com>
	<4d569c330612121817u715a0ad2g10b2f7a46a4a26fe@mail.gmail.com>
	<20061213043848.GA23539@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuzdS-0001DC-F5
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 15:05:06 -0800
Received: from sage.xerus.org ([64.74.153.194] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuzdR-00086e-L1
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 15:05:07 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061213043848.GA23539@fieldses.org>
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

On Tue, Dec 12, 2006 at 11:38:49PM -0500, J. Bruce Fields wrote:
> On Tue, Dec 12, 2006 at 09:17:43PM -0500, Kevin Coffman wrote:
> > I believe this looks exactly like the problem discussed here:
> > http://marc.theaimsgroup.com/?l=linux-nfs&m=116225377701186&w=2
> > 
> > I don't recall coming up with a solution.  The theory was possibly a
> > memory leak.
> 
> I don't know.
> 
> > Bruce, could this be related to the leaks recently discovered and plugged?
> 
> There'd be no harm in trying a kernel with those bugs fixed:
> 
> http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.19-rc6-1/linux-2.6.19-rc6-CITI_NFS4_ALL-1.diff
> 
> But I don't think any of those bugs would explain this.

FWIW, I upgraded the server to 2.6.18 yesterday, and have been running
for 29 hours without a problem.  I'll keep my fingers crossed.

Christian

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
