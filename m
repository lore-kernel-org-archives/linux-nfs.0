From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: async vs. sync
Date: Tue, 23 Nov 2004 09:57:18 -0500
Message-ID: <20041123145718.GA15378@fieldses.org>
References: <EXCHG20034NQhEP9w0z00007249@EXCHG2003.microtech-ks.com> <41A25DCB.6020700@int-evry.fr> <41A25FA3.6060000@int-evry.fr> <1101162043.11196.88.camel@lade.trondhjem.org> <41A26EF1.8040404@int-evry.fr> <41A307FF.3080300@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Roger Heflin <rheflin@atipa.com>, Olaf Kirch <okir@suse.de>,
	nfs@lists.sourceforge.net, mci-unix@int-evry.fr
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWc6e-0003kF-B7
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 06:57:24 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CWc6d-00063z-6r
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 06:57:24 -0800
To: jehan procaccia <jehan.procaccia@int-evry.fr>
In-Reply-To: <41A307FF.3080300@int-evry.fr>
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

On Tue, Nov 23, 2004 at 10:50:55AM +0100, jehan procaccia wrote:
> This is what I expect in term of performances . I will continue my 
> requests on the DEll/EMC hotline , but maybe the security of that AX100 
> storage Processor (raid5, spare disk, double fiber attachement, UPS) 
> allows me to use async export mode in such a case ?

No.  The problem with the async export option is that it allows the
server to tell the client that data is safely committed to disk when it
hasn't actually been.  So the risk is that the nfs server will fail
while valuable data is still sitting in its memory.  It's the server
itself that's the weak point, not the storage.

--Bruce Fields


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
