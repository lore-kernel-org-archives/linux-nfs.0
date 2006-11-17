From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: lockd and krb5
Date: Fri, 17 Nov 2006 13:44:38 -0500
Message-ID: <20061117184438.GF11882@fieldses.org>
References: <200611161137.28079.hcb@chaoticmind.net>
	<200611161702.38857.hcb@chaoticmind.net>
	<20061116162758.GA28645@fieldses.org>
	<200611170922.40447.hcb@chaoticmind.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gl8hj-0005JU-A5
	for nfs@lists.sourceforge.net; Fri, 17 Nov 2006 10:44:48 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gl8hf-0000I6-7L
	for nfs@lists.sourceforge.net; Fri, 17 Nov 2006 10:44:44 -0800
To: Helge Bahmann <hcb@chaoticmind.net>
In-Reply-To: <200611170922.40447.hcb@chaoticmind.net>
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

On Fri, Nov 17, 2006 at 09:22:40AM +0100, Helge Bahmann wrote:
> > > > Is the KDE startup that often triggers this at initial login, or at
> > > > some other time?
> > >
> > > seems completely erratic; it happens both at initial login as well as
> > > second login (after successful logout, but before credentials expire); if
> > > there is any regularity at all then it seems that initial login seems
> > > more likely to succeed
> >
> > Is the filesystem exported under both secuirty flavors (krb5 and sys),
> > with the export options otherwise the same?
> 
> it is exported to the following clients:
> *(ro,all_sqash,fsid=9)
> test.client.for.auth_unix(rw,sync,fsid=9)
> gss/krb5(rw,sync,fsid=9)

Do you see the same problems if your exports all have the same options?
E.g.

	*(rw,sync,fsid=9)
	gss/krb5(rw,sync,fsid=9)

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
