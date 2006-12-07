From: David Teigland <teigland@redhat.com>
Subject: Re: [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Thu, 7 Dec 2006 09:30:43 -0600
Message-ID: <20061207153043.GB14548@redhat.com>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
	<70549752c06e54117024429649fd7aa813f21bec.1165380893.git.bfields@citi.umich.edu>
	<20061206154951.GB16378@redhat.com>
	<20061206195722.GH1714@fieldses.org>
	<20061206205822.GB25322@redhat.com>
	<20061206212347.GA25465@fieldses.org>
	<20061206214231.GC25322@redhat.com>
	<20061206220029.GC25465@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsLIP-000135-HK
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 07:36:25 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GsLIN-00078u-Lj
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 07:36:27 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061206220029.GC25465@fieldses.org>
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

On Wed, Dec 06, 2006 at 05:00:29PM -0500, J. Bruce Fields wrote:
> On Wed, Dec 06, 2006 at 03:42:31PM -0600, David Teigland wrote:
> > Oh yeah, that's painful, I knew it sounded too easy.
> 
> Yeah.  Well, we could try to teach GFS2 to reliably cancel posix locks.
> I think that may turn out to be necessary some day anyway.

Some posix locks would be trivial to cancel and others would be hard.  If
gfs_controld has not yet read the op from the kernel's send_list, then we
just remove the op and it never "goes out".  After gfs_controld has taken
it and sent it, then it's had its effect and, as you reminded me, is
unreversible without introducing new complexity (like the provisional
locks which sound unpleasant).

In practice, I don't know how likely we are to find ops that haven't been
sent yet--the easy ones to cancel.


> Or we could look at why we're timing out and figure out whether there's
> something else we should be doing instead in that case.  In what
> situations is the GFS2 lock call likely to take overly long?

Again, in practice, I really don't know how long a sent lock could be
delayed.  When everything is running normally the only delay is between
sending the message (through the openais comms api) and receiving it back
again (which is when we grant it).  So, for us it's completely depedent on
how long the delivery of messages could be delayed by openais due to
openais dealing with configuration changes in the cluster.

Dave


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
