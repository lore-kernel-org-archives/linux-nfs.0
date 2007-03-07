From: Neil Brown <neilb@suse.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 09:17:52 +1100
Message-ID: <17903.14864.866148.254685@notabene.brown>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<20070307224054.b2cbc294.simon.peter@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	nfs@lists.sourceforge.net
To: Simon Peter <simon.peter@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP4SO-0004GT-3P
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:18:00 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HP4SP-0005y0-EC
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:18:02 -0800
In-Reply-To: message from Simon Peter on Wednesday March 7
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

On Wednesday March 7, simon.peter@gmx.de wrote:
> 
> I think what Tom had in mind was to stat all directories once, remember
> their values, have inotify keep an eye on 'em and whenever they change,
> update the remembered values. This way, disk access would only have to
> be done whenever something changes, which is when the disk is spun up
> anyway.

There is certainly some sense in that approach.  I don't think
inotify is needed though.  The only part of the stat information we
are interested in is major/minor/inode numbers, and they don't change.

We could possibly stat everything that seems to be interesting once
and store the details.
When a request comes in, match against the records to find a path,
then double-check the path still matches.  If it does, good.  If not,
take the long way around again.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
