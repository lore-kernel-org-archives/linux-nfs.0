From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/3] NFS: Ensure we support selinux xattrs
Date: Wed, 24 Jan 2007 12:40:03 -0800
Message-ID: <1169671203.6280.26.camel@lade.trondhjem.org>
References: <20070124195307.21259.64156.stgit@lade.trondhjem.org>
	<20070124195457.21259.53047.stgit@lade.trondhjem.org>
	<1169669288.15390.155.camel@moss-spartans.epoch.ncsc.mil>
	<Pine.LNX.4.64.0701241228050.3606@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>,
	Jim Meyering <meyering@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Paris <eparis@redhat.com>, James Morris <jmorris@namei.org>,
	nfs@lists.sourceforge.net, Stephen Smalley <sds@tycho.nsa.gov>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9ovs-00012Z-8Q
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:41:24 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H9ovr-0003Ab-Q9
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:41:26 -0800
In-Reply-To: <Pine.LNX.4.64.0701241228050.3606@woody.linux-foundation.org>
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

On Wed, 2007-01-24 at 12:29 -0800, Linus Torvalds wrote:
> 
> On Wed, 24 Jan 2007, Stephen Smalley wrote:
> > 
> > I don't think you want to just set the incore inode security state on
> > the client side, as that won't be preserved.
> 
> I agree. The fix seems much worse than the problem.
> 
> It doesn't seem to be a kernel bug (except insofar that you can argue that 
> enabling ACL's at all is a bug), and it also doesn't look like a 
> regression.

Fair enough. Please drop this patch then.

Trond

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
