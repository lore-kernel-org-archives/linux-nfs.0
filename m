From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH kNFSd ] nlm: fix f_count leak
Date: Thu, 24 Mar 2005 07:30:09 -0300
Message-ID: <20050324103009.GA8410@logos.cnet>
References: <20050323141612.12609.patches@notabene> <E1DDwOF-0003IA-Gw@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DEzK9-0005iA-BM
	for nfs@lists.sourceforge.net; Fri, 25 Mar 2005 16:38:45 -0800
Received: from hera.kernel.org ([209.128.68.125])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DEzK6-0000cI-SO
	for nfs@lists.sourceforge.net; Fri, 25 Mar 2005 16:38:45 -0800
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <E1DDwOF-0003IA-Gw@notabene.cse.unsw.edu.au>
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

On Wed, Mar 23, 2005 at 02:18:39PM +1100, NeilBrown wrote:
> Hi,
>  The following patch is probably appropriate for 2.4.30.  The problem
> it fixes is not a major one (no security or data corruption issues)
> but is an occasional annoyance, and the fix is trivial (and tested).

Applied, thanks Neil.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
