From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.6 lockupy
Date: Wed, 26 May 2004 17:37:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040526213732.GG2827@fieldses.org>
References: <20040526211115.GI6931@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT65h-00037x-8A
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 14:37:37 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BT65g-0004rw-Sa
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 14:37:37 -0700
Received: from bfields by pumpkin.fieldses.org with local (Exim 4.34)
	id 1BT65d-0001Cg-3b
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 17:37:33 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20040526211115.GI6931@polop.usc.edu>
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

On Wed, May 26, 2004 at 02:11:16PM -0700, Garrick Staples wrote:
> I tried Trond's 2.6.6 patches at his website, but those brokes things
> considerably.  Since I don't have any actual Oops messages, anyone have any
> experimental deadlock-fixing patches they want me to test? :)

Note that Trond's patches are client-side only, so shouldn't affect your
servers one way or another (unless I'm misunderstanding what your
setup).--b.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
