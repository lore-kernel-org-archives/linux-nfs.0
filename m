From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv4 Active-Active Cluster Queries
Date: Thu, 20 Jul 2006 09:52:06 -0400
Message-ID: <20060720135206.GC20263@fieldses.org>
References: <44BF54250200007F0000E3E0@lucius.provo.novell.com>
	<44BF5EF80200007F0000E3E4@lucius.provo.novell.com>
	<44BF5F580200007F0000E3E7@lucius.provo.novell.com>
	<44BF5F8B0200007F0000E3EA@lucius.provo.novell.com>
	<44BF607D0200007F0000E3ED@lucius.provo.novell.com>
	<44BF6B4F0200007F0000E3F6@lucius.provo.novell.com>
	<44BF6B870200007F0000E3F9@lucius.provo.novell.com>
	<44BF6BA30200007F0000E3FC@lucius.provo.novell.com>
	<44BF6BE60200007F0000E3FF@lucius.provo.novell.com>
	<44BF6BE5.6FDC.007F.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3Yws-00032I-9X
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 06:52:19 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G3Ywl-0003Jm-Fd
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 06:52:12 -0700
To: Rajat Upadhyaya <urajat@novell.com>
In-Reply-To: <44BF6BE5.6FDC.007F.0@novell.com>
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

On Thu, Jul 20, 2006 at 12:11:26AM -0600, Rajat Upadhyaya wrote:
> I have been working on setting up NFSv4 in cluster scenario. But when
> it comes to an Active-Active setup, it seems there are a few problems. 

Yes.  Even active-passive failover is problematic right now, mainly
because the method we use for storing reboot recovery information
(analagous to the state recorded by statd) is still in flux.

We're aware of these problems and working on solving them.  There are
some rough (possibly out of date notes) here:

http://wiki.linux-nfs.org/index.php/Cluster_Coherent_NFS_design

but those are more of interest to someone working on design of a
solution than to someone trying to set up and use any of this (which we
don't recommend doing yet).

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
