From: Daniel Phillips <phillips@phunq.net>
Subject: KDB?
Date: Fri, 28 Sep 2007 18:51:24 -0700
Message-ID: <200709281851.24752.phillips@phunq.net>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	<20070928114930.2c201324.akpm@linux-foundation.org>
	<1191006971.6702.25.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	lkml <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-pm <linux-pm@lists.linux-foundation.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbRUg-0002lo-PZ
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 18:51:46 -0700
Received: from phunq.net ([64.81.85.152] helo=moonbase.phunq.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IbRUj-0002fD-46
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 18:51:51 -0700
In-Reply-To: <1191006971.6702.25.camel@heimdal.trondhjem.org>
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

On Friday 28 September 2007 12:16, Trond Myklebust wrote:
> crash> bt 3188

crash> ps|grep ps

Hey, that looks just like kdb!  But I heard that kgdb is better in every 
way than kdb.

Innocently yours,

Daniel

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
