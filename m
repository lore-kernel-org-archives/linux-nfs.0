From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NSM lock recovery fails too often
Date: Fri, 12 Mar 2004 08:47:17 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07BBC@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B1q0O-0002Ml-4u
	for nfs@lists.sourceforge.net; Fri, 12 Mar 2004 08:59:28 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B1pP1-00013h-Ve
	for nfs@lists.sourceforge.net; Fri, 12 Mar 2004 08:20:51 -0800
Received: from frejya.corp.netapp.com (frejya [10.57.157.119])
	by mx01.netapp.com (8.12.10/8.12.10/NTAP-1.4) with ESMTP id i2CGlJJC012959
	for <nfs@lists.sourceforge.net>; Fri, 12 Mar 2004 08:47:19 -0800 (PST)
Received: from svlexc01.hq.netapp.com (svlexc01.corp.netapp.com [10.10.22.171])
	by frejya.corp.netapp.com (8.12.9/8.12.9/NTAP-1.5) with ESMTP id i2CGlJ30002494
	for <nfs@lists.sourceforge.net>; Fri, 12 Mar 2004 08:47:19 -0800 (PST)
To: <nfs@lists.sourceforge.net>
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

hi all-

so we need two solutions:  one for legacy 2.4 and one going forward
on 2.6.

for 2.4, i'd like to see one of the statd patch alternatives
incorporated into the nfs-utils distribution as soon as possible
so that all Linux distributors can pick up an approved patch for
their 2.4-based distributions.  which alternative is the favorite?
this should be addressed quickly.

for 2.6, olaf's work has promise.


> -----Original Message-----
> From: Olaf Kirch [mailto:okir@suse.de]=20
> Sent: Tuesday, March 09, 2004 7:59 AM
> To: Trond Myklebust
> Cc: Lever, Charles; nfs@lists.sourceforge.net
> Subject: Re: [NFS] NSM lock recovery fails too often
>=20
>=20
> On Tue, Mar 09, 2004 at 10:47:42AM -0500, Trond Myklebust wrote:
> > P=E5 ty , 09/03/2004 klokka 10:10, skreiv Olaf Kirch:
> > > What I was referring to was the ability to have several=20
> RPC programs=20
> > > on a single svc_sock server side; e.g. NFS and NFSACL, or NLM and=20
> > > NSM. Pretty much the way svc_register from the good ole=20
> sunrpc code=20
> > > works.
> >=20
> > Oh, sorry...
> >=20
> > Hmm... Any reason why you couldn't put them all on port=20
> 2049 with this=20
> > patch? Would that be less efficient than having two sets of threads?
>=20
> No, you could put all of them on the same port. The problem=20
> is that you want lockd and nfsd to be two different=20
> processes, so you can shut down nfsd without disrupting lockd.
>=20
> Olaf
> --=20
> Olaf Kirch     |  Stop wasting entropy - start using predictable
> okir@suse.de   |  tempfile names today!
> ---------------+=20
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
