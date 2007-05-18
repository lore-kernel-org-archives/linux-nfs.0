From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Fri, 18 May 2007 15:42:33 -0400
Message-ID: <20070518194233.GF4843@fieldses.org>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
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
	id 1Hp8LS-0004w9-4V
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 12:42:34 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hp8LT-0000v1-GW
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 12:42:37 -0700
In-Reply-To: <1179516988.23385.171.camel@trinity.ogc.int>
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

On Fri, May 18, 2007 at 02:36:28PM -0500, Tom Tucker wrote:
> On Fri, 2007-05-18 at 15:24 -0400, J. Bruce Fields wrote:
> > I assume these massive printk's are meant to be dprintk's (if they're
> > meant to be left in at all).
> 
> It shows up once per mount. I thought it was useful, but perhaps not...

Especially for a server with a few clients, it'd be a lot of noise in
the logs, for something that's a normal occurrence.

But if you think it'd be helpful for debugging, then leave it as a
dprintk....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
