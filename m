From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Move (mv) hangs with NFSv4
Date: Wed, 16 Mar 2005 12:47:04 -0500
Message-ID: <20050316174704.GD21258@fieldses.org>
References: <41B61C89.2060000@drzeus.cx> <20041207211715.GQ31250@fieldses.org> <41B6E933.4090708@drzeus.cx> <41D84216.9060504@drzeus.cx> <20050312185119.GA1064@fieldses.org> <42346C15.4080402@drzeus.cx> <20050313164804.GA10992@fieldses.org> <4235B5C4.7060800@drzeus.cx> <20050315223125.GE11916@fieldses.org> <42382772.9030303@drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBcbP-00049A-3B
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 09:46:39 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DBcbM-0005Jz-Ii
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 09:46:39 -0800
To: Pierre Ossman <drzeus-list@drzeus.cx>
In-Reply-To: <42382772.9030303@drzeus.cx>
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

On Wed, Mar 16, 2005 at 01:32:50PM +0100, Pierre Ossman wrote:
> No change in behaviour from the last attempt. idmapd keeps running just
> fine.
> Dump from new run included.

OK, thanks for the data.  It still looks like a server-side idmapping
problem.  Next time it gets into this state, it would be interesting to
know whether sending rpc.idmapd a SIGHUP (or just restarting it) makes
any difference.  I'll try to find the time to investigate further
later this week....--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
