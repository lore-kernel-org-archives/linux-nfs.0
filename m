From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 00/33] SVC Transport Switch
Date: Fri, 28 Sep 2007 14:51:28 +1000
Message-ID: <18172.34896.98978.904440@notabene.brown>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ib7p8-0008NW-IA
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 21:51:35 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ib7pB-0002oV-68
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 21:51:39 -0700
In-Reply-To: message from Tom Tucker on Wednesday September 26
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

On Wednesday September 26, tom@opengridcomputing.com wrote:
> 
> I've attempted to organize the patchset such that logical changes are 
> clearly reviewable without too much clutter from functionally empty name
> changes.  

And you did a very thorough job, thanks!

Just a few minor issues as noted in previous emails.  Most of them can
be addressed by incremental patches rather than respinning the whole
series.  I'm just not sure about where the IP-address info should
live.  Maybe other people have opinions???

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
