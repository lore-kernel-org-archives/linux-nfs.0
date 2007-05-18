From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC, PATCH 4/15] knfsd: map null socket to SOCK_STREAM
	in	svc_max_payload
Date: Fri, 18 May 2007 14:48:02 -0400
Message-ID: <20070518184802.GC4843@fieldses.org>
References: <1179510307.23385.117.camel@trinity.ogc.int>
	<20070518182850.GA4843@fieldses.org>
	<1179513640.23385.137.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp7Ug-0007sr-UC
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:48:02 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hp7Ui-0002L0-IW
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:48:05 -0700
In-Reply-To: <1179513640.23385.137.camel@trinity.ogc.int>
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

On Fri, May 18, 2007 at 01:40:40PM -0500, Tom Tucker wrote:
> Yes, however, we don't know what it's going to end up being yet and I'd
> like to get this code reviewed, so I can work the issues in parallel.

Sure.

But I guess some questions will be easiest to answer when the two are
completely integrated.

> BTW, the current transport switch (before the mods) is up and running in
> several locations. 

OK!

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
