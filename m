From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] Add `no_acl' nfs export option
Date: Tue, 15 Jul 2003 09:13:24 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16147.14612.324419.294401@gargle.gargle.HOWL>
References: <200307081655.17510.agruen@suse.de>
	<200307141309.44623.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org,
   Steve Dickson <SteveD@redhat.com>,
   =?iso-8859-1?q?R=FCdiger=20Oertl?= <ro@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19cCVz-0000A8-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 16:13:51 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <agruen@suse.de>) (for <nfs@lists.sourceforge.net>)
	(for <linux-fsdevel@vger.kernel.org>) (for <SteveD@redhat.com>)
	(for <ro@suse.de>) By note With Smtp ;
	Tue, 15 Jul 2003 09:13:44 +1000
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: message from Andreas Gruenbacher on Monday July 14
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Monday July 14, agruen@suse.de wrote:
> Hello,
> 
> I noticed that the bit I wanted is already reserved in nfs-utils-1.0.4. Here 
> is an updated nfs-utils patch. I am also attaching a patch against 
> linux-2.6.0-test1.
> 
> Could someone please reserve the bit? Thanks.

I'll definately reserve the bit, but I'm not very comfortable about
this concept.
My problem is that it doesn't seem clear how a sysadmin would decide
how to set this bit.  It is not clear, at least from the manpage
entry, exactly what the costs/benefits are of each setting, or how to
find out whether given clients need a particular setting.

Also, the manpage entry says in part:

>    The
> +.I no_acl
> +option should be used for nfs exports with acl support that are exported
> +to NFSv2 clients, or to NFSv3 clients that don't use the ACCESS RPC.

Surely the nfs server can detect itself if a filesystem supports ACLs,
and if a given request is arriving via NFSv2 or not, so it should be
able to assume "no_acl" in that case.

However this is actually a bit simplistic.  I think some NFSv2
clients, solaris in particular, does not depend on the mode but
performs zero-byte read and write requests to perform an equivalent
function to ACCESS.

Can you tell me concisely but precisely, possibly in the form of a
manpage entry,
  What is the cost of always using no_acl?
  What is the cost of never using no_acl?
  How do I determine which cost is greater in a given situation?

It would really like it if the option could be avoided altogether.
e.g. default to assume "no_acl" but switch to "acl" for a given client
for v3 access if an ACCESS request is seen, and for v2 access if a
zero byte READ or WRITE is seen.  Would that even come close to
working?

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
