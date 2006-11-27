From: Chris Caputo <ccaputo@alt.net>
Subject: Re: [PATCH 2.6.19-rc6] sunrpc: fix race condition
Date: Mon, 27 Nov 2006 20:54:02 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0611272037420.24703@nacho.alt.net>
References: <Pine.LNX.4.64.0611271900120.10489@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GonUM-0005b3-3Q
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 12:54:06 -0800
Received: from nacho.alt.net ([207.14.113.18])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GonUL-0007to-AK
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 12:54:07 -0800
To: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.64.0611271900120.10489@nacho.alt.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 27 Nov 2006, Chris Caputo wrote:
> From: Chris Caputo <ccaputo@alt.net>
> [PATCH 2.6.19-rc6] sunrpc: fix race condition

Turns out my patch is buggy.  Don't use it.

Chris

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
