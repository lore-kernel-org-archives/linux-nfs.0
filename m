From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 00/33] SVC Transport Switch
Date: Fri, 28 Sep 2007 12:39:07 -0500
Message-ID: <1191001147.10604.101.camel@trinity.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<18172.34896.98978.904440@notabene.brown>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, Chuck Lever <cel@citi.umich.edu>,
	gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbJpC-0004jj-PY
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 10:40:26 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbJpG-0000Kk-Mz
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 10:40:31 -0700
In-Reply-To: <18172.34896.98978.904440@notabene.brown>
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

On Fri, 2007-09-28 at 14:51 +1000, Neil Brown wrote:
> On Wednesday September 26, tom@opengridcomputing.com wrote:
> > 
> > I've attempted to organize the patchset such that logical changes are 
> > clearly reviewable without too much clutter from functionally empty name
> > changes.  
> 
> And you did a very thorough job, thanks!
> 

Thanks,

> Just a few minor issues as noted in previous emails.  Most of them can
> be addressed by incremental patches rather than respinning the whole
> series.  I'm just not sure about where the IP-address info should
> live.  Maybe other people have opinions???
> 

I've already redone the patchset for whitespace cleanup and to handle a
few checkpatch.pl style issues. How about if I roll in your suggestions,
repost the whole thing and then go to incremental after that?

Thoughts?
Tom
> NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
