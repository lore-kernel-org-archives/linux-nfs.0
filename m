From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] NFS4XDR get rid of warning
Date: Fri, 12 Sep 2003 12:33:54 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16225.12434.398790.891507@notabene.cse.unsw.edu.au>
References: <20030909150434.3df7dc45.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xdl6-00087N-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Sep 2003 19:34:04 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19xdl6-0005b4-Ad
	for nfs@lists.sourceforge.net; Thu, 11 Sep 2003 19:34:04 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <shemminger@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 12 Sep 2003 12:33:58 +1000
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: message from Stephen Hemminger on Tuesday September 9
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

On Tuesday September 9, shemminger@osdl.org wrote:
> On 2.6.0-test5 there is a warning because of calling return with an argument
> on a void function. The root cause is putting a return statement in a macro
> (evil side effect).
> 
> Change ENCODE_SEQID_OP_TAIL to be a more proper macro, and add the return's
> where needed.

Looks good,  thanks.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
