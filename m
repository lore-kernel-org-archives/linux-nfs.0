From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC] patch for dealing with short reads/writes...
Date: Sat, 06 Mar 2004 14:55:23 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078602923.2055.5.camel@nidelv.trondhjem.org>
References: <1078550670.19081.15.camel@nidelv.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Azi0b-0003NU-No
	for nfs@lists.sourceforge.net; Sat, 06 Mar 2004 12:02:53 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AzhtO-0007tJ-B5
	for nfs@lists.sourceforge.net; Sat, 06 Mar 2004 11:55:26 -0800
Received: from trondmy by nidelv.trondhjem.org with local (Exim 4.30)
	id 1AzhtM-0000mU-0R
	for nfs@lists.sourceforge.net; Sat, 06 Mar 2004 14:55:24 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <1078550670.19081.15.camel@nidelv.trondhjem.org>
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

P=E5 lau , 06/03/2004 klokka 00:24, skreiv Trond Myklebust:
> The following patch (which should apply at the end of the existing
> linux-2.6.4-NFS4_ALL.dif) attempts to deal with these cases. If the
> server has made at least some progress, we retry the read/write attempt
> starting at the point where the server left off.
> In the case of NFSv3/v4 unstable writes, the possibility that the server
> may reboot is giving me headaches, so I prefer to first retry the entire
> write as a stable write, then continue at wherever the server leaves
> off...
>=20
> Patch is completely untested as of yet...

OK. Patch has been replaced by a version that not only actually
compiles, but also appears to work. It has therefore been queued up in
the latest NFS4_ALL patch.

I believe that leaves us with just one remaining known spec violation in
our NFSv2/v3 clients: we're not yet prepared to issue READDIR requests
for buffer sizes of more than PAGE_SIZE in length.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
