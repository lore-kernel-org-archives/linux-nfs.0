From: Helge Bahmann <hcb@chaoticmind.net>
Subject: Re: lockd and krb5
Date: Fri, 17 Nov 2006 12:38:52 +0100
Message-ID: <200611171238.52930.hcb@chaoticmind.net>
References: <200611161137.28079.hcb@chaoticmind.net>
	<200611161702.38857.hcb@chaoticmind.net>
	<20061116162758.GA28645@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gl23i-0000oO-DO
	for nfs@lists.sourceforge.net; Fri, 17 Nov 2006 03:39:02 -0800
Received: from m4s07.vlinux.de ([83.151.27.105])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1Gl23j-0002St-5N
	for nfs@lists.sourceforge.net; Fri, 17 Nov 2006 03:39:03 -0800
Received: from pd95de6fe.dip.t-dialin.net ([217.93.230.254])
	by m4s07.vlinux.de with asmtp (Exim 3.35 #1 (Debian))
	id 1Gl23f-0005kI-00
	for <nfs@lists.sourceforge.net>; Fri, 17 Nov 2006 12:38:59 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <20061116162758.GA28645@fieldses.org>
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

Am Donnerstag, 16. November 2006 17:27 schrieb J. Bruce Fields:
> On Thu, Nov 16, 2006 at 05:02:38PM +0100, Helge Bahmann wrote:
> > Am Donnerstag, 16. November 2006 15:21 schrieb Kevin Coffman:
> > > I can't help directly with the locking behavior, but could it be
> > > related to expiring Kerberos credentials and/or gss contexts?
> >
> > no credentials are valid
> >
> > > Is the KDE startup that often triggers this at initial login, or at
> > > some other time?
> >
> > seems completely erratic; it happens both at initial login as well as
> > second login (after successful logout, but before credentials expire); if
> > there is any regularity at all then it seems that initial login seems
> > more likely to succeed
>
> Is the filesystem exported under both secuirty flavors (krb5 and sys),
> with the export options otherwise the same?

Is there a better tool than tcpdump to capture the rpc traffic? I can try to 
capture a failed (auth-krb5) and succesfull (auth-sys)  login session, maybe 
something stands out

best regards

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
