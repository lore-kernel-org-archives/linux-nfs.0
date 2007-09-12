From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] sunrpc: make closing of old temporary
	sockets	work (was: problems with lockd in 2.6.22.6)
Date: Wed, 12 Sep 2007 10:24:00 -0400
Message-ID: <20070912142400.GC24998@fieldses.org>
References: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de>
	<20070912133729.GA24998@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, trond.myklebust@fys.uio.no
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVT8O-0005Yh-Ok
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 07:24:05 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IVT8P-0000vJ-KJ
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 07:24:09 -0700
In-Reply-To: <20070912133729.GA24998@fieldses.org>
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

On Wed, Sep 12, 2007 at 09:37:29AM -0400, bfields wrote:
> So the fact that this changes the behavior means that sk_inuse is taking
> on negative values.

Uh, no, I misread the tests, sorry.  I'm not awake.--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
