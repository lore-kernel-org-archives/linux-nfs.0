From: "Laurenz, Dirk" <Dirk.Laurenz-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>
Subject: RE: Sm-notify
Date: Sat, 28 Jun 2008 09:38:57 +0200
Message-ID: <FC3FA7C4E1CA2348B5579A68B24556E9DA4AD419DD@ABGEX72E.FSC.NET>
References: <485A6033.3090301@citi.umich.edu>
	<20080625193757.GF12629@fieldses.org>
	<FC3FA7C4E1CA2348B5579A68B24556E9DA4AF2946C@ABGEX72E.FSC.NET>
	<46260.192.168.1.70.1214533375.squirrel@neil.brown.name>
	<FC3FA7C4E1CA2348B5579A68B24556E9DA4AD413AB@ABGEX72E.FSC.NET>
 <18533.31573.855657.391140@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>,
	"Oeltze, Benjamin" <Benjamin.Oeltze-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dgate10.fujitsu-siemens.com ([80.70.172.49]:63646 "EHLO
	dgate10.fujitsu-siemens.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754450AbYF1HjA convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Jun 2008 03:39:00 -0400
In-Reply-To: <18533.31573.855657.391140-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

i, the time out is from node a to b seconds, but from node b to a 15 minutes.
what I saw was, that the handle changed in /var/lib/nfs/rmtab from 0x000002 to 0x000003 although
the fsid is the same on both nodes.
how can the 15minute timeout occur?

Mit freundlichem Gruss,


Dirk Laurenz
Systems Engineer
Fujitsu Siemens Computers
R DE ISC SOP PS N/O
Hildesheimer Strasse 25
30880 Laatzen
Germany
Telephone:              +49 511 84 89 18 08
Telefax:                +49 511 84 89 25 18 08
Mobile:                 +49 170 22 10 781
Email:                  mailto:dirk.laurenz-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org
Internet:               http://www.fujitsu-siemens.com
Firmenangaben:  http://www.fujitsu-siemens.de/imprint.html

> -----Original Message-----
> From: Neil Brown [mailto:neilb@suse.de]
> Sent: Saturday, June 28, 2008 1:44 AM
> To: Oeltze, Benjamin
> Cc: Laurenz, Dirk; linux-nfs@vger.kernel.org
> Subject: RE: Sm-notify
>
> On Friday June 27, Benjamin.Oeltze-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org wrote:
> > Hi,
> > maybe I can specify Dirks question.
>
> Thanks.
>
> >
> > We are trying to set up a NFS Cluster and want to use sm-notify to inform the
> Clients if the Server has failed over.
> > We have found a Howto that says: sm-notify uses files under /var/lib/nfs/sm to
> determine the Clients it has to inform.
> > Our Problem is, that ther are no files in this place even if we connet with a client.
> Is there anything we have forgotten?
>
> Files do not get created in /var/lib/nfs/sm until the client tried to
> get a lock on some file (or part of a file).  Then the file is
> created.
> Some minutes after the last lock is dropped, the file should be
> removed (though I recall there were some issues related to that, it
> might depend on exactly which kernel you are running).
>
> If no file locking is involved, there is no need to inform the client
> of failover.  They will transparently start accessing the new server
> through the old IP address, possible after a short timeout.
>
> NeilBrown

