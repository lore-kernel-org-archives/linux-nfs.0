From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS FAQ updates
Date: Sun, 13 Mar 2005 15:05:37 -0500
Message-ID: <20050313200537.GB11748@fieldses.org>
References: <482A3FA0050D21419C269D13989C611307CF4C1E@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	NeilBrown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAZKv-00024h-Vj
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 12:05:17 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAZKu-0000N6-IY
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 12:05:17 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611307CF4C1E@lavender-fe.eng.netapp.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Sun, Mar 13, 2005 at 11:37:26AM -0800, Lever, Charles wrote:
> Why should I disable subtree checking on my NFS server exports?
>   http://nfs.sourceforge.net/index.cel.php#faq_c7

Kerberos doesn't solve exactly the problem that subtree checking
attempts to solve.  My attempt at a concise way of putting this (maybe you
can think of a better way):

	Use Kerberos and/or NFSv4 when they become available: it may
		still be possible for a user of NFS over Kerberos to
		access files outside of the exported subtree.  However,
		it should not be possible for them to fake their identity,
		so they should not be able to read files that they do
		not have permissions to.

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
