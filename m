From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: ANNOUNCE: nfs-utils 1.0.7-pre2
Date: Wed, 15 Dec 2004 14:37:10 -0500
Message-ID: <20041215193710.GB30441@fieldses.org>
References: <16825.223.924965.582375@cse.unsw.edu.au> <20041215191043.GB4032@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CeexP-0002Ns-Ft
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 11:37:07 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CeexO-0003uK-RR
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 11:37:07 -0800
To: Robert Schwebel <robert@schwebel.de>
In-Reply-To: <20041215191043.GB4032@pengutronix.de>
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

On Wed, Dec 15, 2004 at 08:10:43PM +0100, Robert Schwebel wrote:
> On Fri, Dec 10, 2004 at 12:50:23PM +1100, Neil Brown wrote:
> > I have made available a second pre-release of nfs-utils 1.0.7.
> 
> Any chance that you include our autotools patch in this release? Or is
> it too intrusive? In this case I would be interested in some further
> feedback. 

It looks like a large patch.  Neil seems to want to get 1.0.7 out in the
next few days.

I'd be happy to take the patch, include it in the citi nfs-utils patch
series for a while, then push it to Neil after 1.0.7.  That way I'd get
the chance to make any necessary fixes for nfsv4/gss before it went in.
Does that sound OK?

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
