From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC, PATCH 4/15] knfsd: map null socket to
	SOCK_STREAM	in	svc_max_payload
Date: Fri, 18 May 2007 13:50:30 -0500
Message-ID: <1179514230.23385.145.camel@trinity.ogc.int>
References: <1179510307.23385.117.camel@trinity.ogc.int>
	<20070518182850.GA4843@fieldses.org>
	<1179513640.23385.137.camel@trinity.ogc.int>
	<20070518184802.GC4843@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp7X6-000897-W0
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:50:33 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp7X9-0002vb-Pz
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:50:36 -0700
In-Reply-To: <20070518184802.GC4843@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-05-18 at 14:48 -0400, J. Bruce Fields wrote:
> On Fri, May 18, 2007 at 01:40:40PM -0500, Tom Tucker wrote:
> > Yes, however, we don't know what it's going to end up being yet and I'd
> > like to get this code reviewed, so I can work the issues in parallel.
> 
> Sure.
> 
> But I guess some questions will be easiest to answer when the two are
> completely integrated.

I also think by considering the two together, you can get a better
understanding of what's actually needed.

> 
> > BTW, the current transport switch (before the mods) is up and running in
> > several locations. 
> 
> OK!
> 
> --b.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
