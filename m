From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: debugging hanging locks
Date: Tue, 17 Aug 2004 20:40:37 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092789637.9393.19.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0408161741020.5649@harp.ngdc.noaa.gov>
	 <1092702159.11722.77.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0408161846440.5649@harp.ngdc.noaa.gov>
	 <1092757186.4030.11.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0408171146190.12428@harp.ngdc.noaa.gov>
	 <1092765798.4030.59.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0408171718050.12428@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxEVl-0007tu-Id
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 17:41:05 -0700
Received: from dh154.citi.umich.edu ([141.211.133.154] helo=lade.trondhjem.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BxEVj-0007cQ-LB
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 17:41:04 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0408171718050.12428@harp.ngdc.noaa.gov>
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

P=E5 ty , 17/08/2004 klokka 19:30, skreiv Ara.T.Howard:
> On Tue, 17 Aug 2004, Trond Myklebust wrote:
>=20
> > P ty , 17/08/2004 klokka 13:50, skreiv Ara.T.Howard:
> >
> >> any ideas how one might try to exercise the kernel's clean-up beyond s=
imply
> >> sending SIGKILL to processes holding locks?  perhaps calls to _exit an=
d
> >> sendend one's self SIGKILL?
> >
> > Just failing to lockf(F_ULOCK) will cause it to trigger, however the
> > races tend to occur if/when you interrupt the actual lockf(F_LOCK) call=
,
> > since that may cause the client to miss a reply from the server.
>=20
> so this code seems to expose the soft timeout bug and/or the kernel not
> cleaning up properly - if you run this and compile it:

...but are you seeing it with a recent 2.4 kernel (2.4.26 or 2.4.27)?

The test you are providing would trigger precisely the race that was
supposed to be fixed by patch I sent you. AFAICS that patch has not been
applied to the 2.4.21-15 source tree.

Cheers,
  Trond


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
