From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] locks: provide a file lease method enabling
	cluster-coherent leases
Date: Thu, 7 Jun 2007 13:05:57 -0400
Message-ID: <20070607170557.GA14463@fieldses.org>
References: <OFB9D089FA.C0E6BE5A-ON882572F1.007D3720-882572F1.007E299C@us.ibm.com>
	<1181086828.6108.11.camel@heimdal.trondhjem.org>
	<f0a71180706061143t1b4a4374qef319deac727815f@mail.gmail.com>
	<f0a71180706070743h4f20f091nf6aa3a7edb95af0c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org,
	David Teigland <teigland@redhat.com>, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Robert Rappaport <robert.rappaport@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HwLR2-0007Jz-QO
	for nfs@lists.sourceforge.net; Thu, 07 Jun 2007 10:06:08 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HwLR4-0003at-JF
	for nfs@lists.sourceforge.net; Thu, 07 Jun 2007 10:06:11 -0700
In-Reply-To: <f0a71180706070743h4f20f091nf6aa3a7edb95af0c@mail.gmail.com>
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

On Thu, Jun 07, 2007 at 10:43:51AM -0400, Robert Rappaport wrote:
> My interpretation of the preceeding is  that there is agreement that
> the functionality currently implemented in __setlease() should be
> exported, even though the exported name may not be __setlease().  Is
> this correct?

Yes.

> If so, that is just fine with me.

OK, good.  I'll revise and post a new series.  (Do people prefer another
mailbomb or a git url?)

> The question that I have now is when do you think it likely that these
> changes get into the released code?  I hope that the plan is to get it
> there fairly soon.

It would seem reasonable to me to put off the question of how to do proper
distributed lease-breaking for now, in which case the remaining patches
seem straightforward enough to me that they could go in now.

My main question is whether the partial disabling of leases looks to the
GFS2 people like reasonable behavior.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
