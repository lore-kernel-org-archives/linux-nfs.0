From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problem starting rpc.svcgssd for NFS4
Date: Tue, 24 Feb 2004 19:46:49 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040225004649.GA12484@fieldses.org>
References: <200402230759.35041.simeon@up.ac.za> <20040223162516.GA4977@fieldses.org> <200402241100.13391.simeon@up.ac.za> <20040224180329.GB10522@fieldses.org> <16443.55307.687362.890855@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simeon Miteff <simeon@up.ac.za>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvnDQ-0004eV-H6
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 16:47:56 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AvnCU-0006hD-8h
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 16:46:58 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16443.55307.687362.890855@notabene.cse.unsw.edu.au>
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

On Wed, Feb 25, 2004 at 10:02:35AM +1100, Neil Brown wrote:
> On Tuesday February 24, bfields@fieldses.org wrote:
> > That should work.  One caveat: there are some potentially serious
> > performance problems with rpcsec_gss over tcp, so make sure you specify
> > proto=tcp.  If you come across any problems in testing, let us know.
> 
> I assume there is a typo in here.
> Can I assume you mean "performance problems with rpcsec_gss over
> *udp*"??

Argh, yes, thanks for the correction.

--Bruce Fields


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
