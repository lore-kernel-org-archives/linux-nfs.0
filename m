From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] knfsd: remove unnecessary BUG_ON's
Date: Fri, 14 Sep 2007 12:50:13 -0400
Message-ID: <20070914165013.GE26622@fieldses.org>
References: <20070912234317.GF13792@fieldses.org>
	<20070914164058.GK21965@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWEMv-0000Jb-Fd
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 09:50:13 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IWEMz-0005TV-1O
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 09:50:18 -0700
In-Reply-To: <20070914164058.GK21965@sgi.com>
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

On Sat, Sep 15, 2007 at 02:40:58AM +1000, Greg Banks wrote:
> On Wed, Sep 12, 2007 at 07:43:17PM -0400, J. Bruce Fields wrote:
> > Trivial patch, but--any objection to removing these assertions?
> > 
> > We set svsk->sk_pool = pool just 30-some lines above, and there's no
> > obvious reason this should have changed, or any other particular reason
> > to assert this here.
> 
> Yeah, you'd think that.  However we saw these BUG_ON()s tripped
> when attempting to port the 2.6.18-based NFS/RDMA patches to a
> 2.6.19-like kernel.  All it takes is for some transport code to get
> confused about the proper way to clear SK_BUSY, and *blam*.  So I
> think they're useful.

OK, I'll take your word for it--dropped.  (But, I'm just curious--do you
remember what the sequence of events was?)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
