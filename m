From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH kNFSd 4 of 18] svcrpc: share code duplicated between auth_unix and auth_null
Date: Tue, 16 Nov 2004 12:55:21 -0500
Message-ID: <20041116175521.GA17973@fieldses.org>
References: <20041116154601.18412.patches@notabene> <E1CTvIn-0004pW-OO@notabene.cse.unsw.edu.au> <20041115220925.2c816f9e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CU7Y7-0005Pg-Q8
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 09:55:27 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CU7Y5-00006k-Th
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 09:55:27 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041115220925.2c816f9e.akpm@osdl.org>
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

On Mon, Nov 15, 2004 at 10:09:25PM -0800, Andrew Morton wrote:
> >  +int
> >  +svcauth_unix_set_client(struct svc_rqst *rqstp)
> 
> I'll make that `static int'.  Please be on the lookout for that.

Whoops, sorry.  Is there a quick easy way to check for this sort of
thing automatically?

--b.


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
