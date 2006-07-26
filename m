From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Wed, 26 Jul 2006 09:00:44 -0400
Message-ID: <20060726130044.GA21273@fieldses.org>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
	<200607250232.37603.a.gruenbacher@computer.org>
	<04075B08-F57D-4842-A7B2-9467DF9A39A2@Sun.COM>
	<200607252215.16735.agruen@suse.de>
	<4654D18B-57AD-4779-80A6-BFD2FCEC4A69@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	nfs@lists.sourceforge.net, "Noveck, Dave" <Dave.Noveck@netapp.com>,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	"Pawlowski,  Brian" <beepy@netapp.com>,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5lcb-00054j-BQ
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 08:48:29 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5lca-0007iG-GD
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 08:48:29 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1G5j0U-0004cL-NJ
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 06:00:59 -0700
To: Sam Falkner <Sam.Falkner@Sun.COM>
In-Reply-To: <4654D18B-57AD-4779-80A6-BFD2FCEC4A69@Sun.COM>
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

On Tue, Jul 25, 2006 at 10:59:25PM -0600, Sam Falkner wrote:
> On Jul 25, 2006, at 2:15 PM, Andreas Gruenbacher wrote:
> >Maybe nobody explained to users how to properly use ACLs to prevent
> >this from happening? The behavior of Solaris chmod(1) is a potential
> >security  hole, although a small one only.
> 
> I remind you that in NFSv4, ACL is not a required attribute.

That's really a statement about servers, not clients, so I'm not
convinced it's relevant here.

It's true that servers are not required to support optional attributes.
But obviously clients may be required to do so if, for example, they
want full control over file permissions.

The chmod-modifies-group-bits scheme only removes one of the more
visible consequences of this fact.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
