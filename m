From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Fri, 9 Mar 2007 09:59:18 -0500
Message-ID: <20070309145918.GC25751@fieldses.org>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<20070307202949.GH26553@fieldses.org>
	<20070309140237.ce6728bf.simon.peter@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	nfs@lists.sourceforge.net
To: Simon Peter <simon.peter@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPgYL-0001zY-Ko
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 06:58:41 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HPgYK-0001Ii-6Z
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 06:58:42 -0800
In-Reply-To: <20070309140237.ce6728bf.simon.peter@gmx.de>
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

On Fri, Mar 09, 2007 at 02:02:37PM +0100, Simon Peter wrote:
> > 	- the filehandle->export mapping that this function tells the
> > 	  kernel about is cached by nfsd for a half-hour.  That time
> > is set a little later in nfsd_fh:
> > 	          qword_printint(f, time(0)+30*60);
> > 	  I don't think there would be any harm to just changing that
> > 	  time(0)+30*60 to 0x7FFFFFFF (== never expire)--nfs-utils
> > 	  should be invalidating that cache explicitly whenever it's
> > 	  needed.  Maybe that should be the default.
> 
> Is there any way that we could see this change incorporated into
> nfs-utils? I certainly would like to have it.

Make a diff showing that change (and nothing else), stick an explanation
of the change and why it's correct at the top, and mail it to Neil cc'd
to this list?....

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
