From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv4 daemons...
Date: Thu, 08 Jan 2004 23:06:14 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1073621173.1398.55.camel@nidelv.trondhjem.org>
References: <1073608448.1380.22.camel@nidelv.trondhjem.org>
	 <1073619719.12271.7.camel@binkley>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: hjl@users.sourceforge.net, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Aenui-0000rY-7Z
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 20:06:24 -0800
To: seth vidal <skvidal@phy.duke.edu>
In-Reply-To: <1073619719.12271.7.camel@binkley>
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

P=E5 to , 08/01/2004 klokka 22:41, skreiv seth vidal:
> On Thu, 2004-01-08 at 19:34, Trond Myklebust wrote:
> > We're at the point now with the NFSv4 project that we'd like to publish
> > the user daemons that are necessary to support the existing client in
> > the 2.6.0 kernel.
> >=20
> > Would it make sense to add these to the existing nfs-utils package?
> >=20
> >=20
>=20
> What type of stability have you seen from these?
> Do you think these might be in a place to benefit from some wider use?

The idmapper in particular is essential if you want to use NFSv4.
Without it, all your files will appear to be owned by nobody:nogroup,
and you will be unable to do anything to change the ownership.

rpc.gssd is necessary if you want to use strong authentication (for
NFSv2/v3 as well as for NFSv4).

The basic design of these 2 daemons has been stable for over a year now,
so they have been fairly well tested in the lab and among the NFSv4
beta-testers.
There are no known bugs in the daemons themselves, however until I'm
done merging the patches to Linus+Andrew, people who wish to actually
use NFSv4 should patch their client kernels with 2.6.1-NFS4_ALL from my
usual site.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
