From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Problem starting rpc.svcgssd for NFS4
Date: Wed, 25 Feb 2004 10:02:35 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16443.55307.687362.890855@notabene.cse.unsw.edu.au>
References: <200402230759.35041.simeon@up.ac.za>
	<20040223162516.GA4977@fieldses.org>
	<200402241100.13391.simeon@up.ac.za>
	<20040224180329.GB10522@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simeon Miteff <simeon@up.ac.za>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvlbB-0007dU-Ni
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 15:04:21 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvlNp-0000VO-Uh
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 14:50:34 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <bfields@fieldses.org>) (for <simeon@up.ac.za>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Wed, 25 Feb 2004 10:02:37 +1100
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Tuesday February 24
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tuesday February 24, bfields@fieldses.org wrote:
> On Tue, Feb 24, 2004 at 11:00:13AM +0200, Simeon Miteff wrote:
> > Thanks! Applying the patch solved the problem. I can mount exports with 
> > -osec=krb5 and stuff.
> > 
> > The main reason why I want to use NFS4 is for the security it provides. While 
> > I understand that NFS4 isn't concidered ready for production systems yet, I'm 
> > wondering, is it a good idea to use -osec=krb5 with NFS3 in the mean-time?
> 
> That should work.  One caveat: there are some potentially serious
> performance problems with rpcsec_gss over tcp, so make sure you specify
> proto=tcp.  If you come across any problems in testing, let us know.

I assume there is a typo in here.
Can I assume you mean "performance problems with rpcsec_gss over
*udp*"??

NeilBrown


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
