From: Olaf Kirch <okir@suse.de>
Subject: Re: Re: "nfs warning: mount version older than kernel" reported for 2.6.4 kernel on Fedora Core 1.0
Date: Mon, 5 Apr 2004 11:19:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040405091948.GN11477@suse.de>
References: <41089CB27BD8D24E8385C8003EDAF7AB084833@karl.alexa.com> <20040319184931.GF29237@perlsupport.com> <1079725155.2530.30.camel@lade.trondhjem.org> <Pine.LNX.4.58.0404040006440.25515@hibernia.jakma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chip Salzenberg <chip@pobox.com>, Guolin Cheng <guolin@alexa.com>,
	"NFSUserList (E-mail)" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAQI0-0007R7-Uf
	for nfs@lists.sourceforge.net; Mon, 05 Apr 2004 02:21:08 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BAQI0-0002mB-Ft
	for nfs@lists.sourceforge.net; Mon, 05 Apr 2004 02:21:08 -0700
To: Paul Jakma <paul@clubi.ie>
In-Reply-To: <Pine.LNX.4.58.0404040006440.25515@hibernia.jakma.org>
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

BTW I just found that the above mentioned kernel message will not go
away entirely unless you patch it out of your kernel.  mount will try
to mount with the highest available kernel mount version by default
(usually 4 for all but very old kernels), but when that fails for some
reason, it will fall back to kernel mount version 3.

Olaf

On Sun, Apr 04, 2004 at 12:08:41AM +0100, Paul Jakma wrote:
> On Fri, 19 Mar 2004, Trond Myklebust wrote:
> 
> > One such change is to allow NFSv2/v3 to use RPCSEC_GSS (BTW: we're
> > *still* waiting to hear from this list about including the
> > RPCSEC_GSS + NFSv4 support daemons into the official nfs-utils) 
> 
> I dont know what the pitfalls would be, but if there arent too many, 
> my vote is "in". As soon as fedora has v4 enabled nfs-utils, i intend 
> to try it with rpcsec_gss.
> 
> regards,
> -- 
> Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
> 	warning: do not ever send email to spam@dishone.st
> Fortune:
> There appears to be irrefutable evidence that the mere fact of overcrowding
> induces violence.
> 		-- Harvey Wheeler
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
