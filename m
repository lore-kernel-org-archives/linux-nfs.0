From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Thu, 7 Dec 2006 11:21:10 -0500
Message-ID: <20061207162110.GA16858@fieldses.org>
References: <20061207152359.GB13613@fieldses.org>
	<OF3AAB0892.7839D917-ON8825723D.0055EEC9-8825723D.00563276@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org,
	David Teigland <teigland@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsLzq-0006Gj-VX
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 08:21:19 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsLzn-0002Iu-Sv
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 08:21:20 -0800
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF3AAB0892.7839D917-ON8825723D.0055EEC9-8825723D.00563276@us.ibm.com>
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

On Thu, Dec 07, 2006 at 07:43:48AM -0800, Marc Eshel wrote:
> nfs-bounces@lists.sourceforge.net wrote on 12/07/2006 07:23:59 AM:
> 
> > On Wed, Dec 06, 2006 at 10:47:46PM -0800, Marc Eshel wrote:
> > >    if (!rv) { /* got fs lock */
> > >        rv = posix_lock_file(file, fl);
> > >        if (rv) { /* did not get posix lock */
> > 
> > If we never request the local lock until after we've gotten the lock
> > from GFS, then this should never happen.  So I think this could just be
> > a BUG_ON(rv)--except that would mean a failure in the lock manager could
> > oops the kernel, so maybe it'd be better just to printk.
> 
> It can happen if you can not allocate memory. 

OK, you're right.

Hm, the NFS client just seems to print out a warning at this point,
though.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
