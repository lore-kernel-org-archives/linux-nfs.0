From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 0/14] A transport switch for knfsd
Date: Thu, 17 May 2007 05:18:21 +1000
Message-ID: <20070516191821.GF9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoP11-0008NM-Dm
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:18:27 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX18h71VKobhChIIuQrKIPu4+fNumnJatvoc=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoP14-0000O6-4N
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:18:30 -0700
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

G'day,

These 14 patches are an experimental transport switch for knfsd.
They're based on Tom Tucker's 01-svc-xprt-switch.patch from the
nfsrdma project November release, but redesigned to provide as simple
and clean an abstraction as possible to new transport-specific code.
Various messy details of flags, reference counts and other behaviour
which are currently redundantly handled in both TCP and UDP code,
will be handled in generic code now.  This makes the task of writing
new transport code easier and less prone to breakage.

These patches have received light testing in a tree similar to 2.6.19
on ia64, and been forward ported without further testing to 2.6.21.
They're intended for testing in Tom's development tree, but are cc'ed
to the Linux mailing list for initial review.

[RFC,PATCH 1/14] knfsd: add transport ops
[RFC,PATCH 2/14] knfsd: delete per transport
[RFC,PATCH 3/14] knfsd: prepare reply per transport
[RFC,PATCH 4/14] knfsd: has_wspace per transport
[RFC,PATCH 5/14] knfsd: max_payload per transport
[RFC,PATCH 6/14] knfsd: add svc_sock_is_connection
[RFC,PATCH 7/14] knfsd: export svc_sock_enqueue, svc_sock_received
[RFC,PATCH 8/14] knfsd: centralise SK_CLOSE handling
[RFC,PATCH 9/14] knfsd: centralise SK_CONN handling
[RFC,PATCH 10/14] knfsd: add SK_LISTENER
[RFC,PATCH 11/14] knfsd: centralise SK_DATA handling
[RFC,PATCH 12/14] knfsd: add svc_sock_get
[RFC,PATCH 13/14] knfsd: add svc_sock_init
[RFC,PATCH 14/14] knfsd: centralise SK_ bits some more

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
