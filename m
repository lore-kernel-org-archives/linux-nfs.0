From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problem starting rpc.svcgssd for NFS4
Date: Tue, 24 Feb 2004 13:03:29 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040224180329.GB10522@fieldses.org>
References: <200402230759.35041.simeon@up.ac.za> <20040223162516.GA4977@fieldses.org> <200402241100.13391.simeon@up.ac.za>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avgur-0001Pe-CV
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 10:04:21 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Avgu5-0001kH-7F
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 10:03:33 -0800
To: Simeon Miteff <simeon@up.ac.za>
In-Reply-To: <200402241100.13391.simeon@up.ac.za>
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

On Tue, Feb 24, 2004 at 11:00:13AM +0200, Simeon Miteff wrote:
> Thanks! Applying the patch solved the problem. I can mount exports with 
> -osec=krb5 and stuff.
> 
> The main reason why I want to use NFS4 is for the security it provides. While 
> I understand that NFS4 isn't concidered ready for production systems yet, I'm 
> wondering, is it a good idea to use -osec=krb5 with NFS3 in the mean-time?

That should work.  One caveat: there are some potentially serious
performance problems with rpcsec_gss over tcp, so make sure you specify
proto=tcp.  If you come across any problems in testing, let us know.

--b.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
