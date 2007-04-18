From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 0/4 Revised] NLM - lock failover
Date: Wed, 18 Apr 2007 14:56:18 -0400
Message-ID: <462669D2.1070209@redhat.com>
References: <46156F3F.3070606@redhat.com> <4625204D.1030509@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, cluster-devel@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeFe1-0001us-Mk
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 12:16:45 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeFe3-0003Ab-V6
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 12:16:48 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3IJGkfC006876
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 15:16:46 -0400
In-Reply-To: <4625204D.1030509@redhat.com>
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

Arjan, I need an objective opinion and am wondering whether you could 
give me some advices ...

I'm quite upset about this Christoph guy and really want to "talk back". 
Will my response be too strong that ends up harm my later on patches ?

-- Wendy

Christoph Hellwig wrote:
> On Tue, Apr 17, 2007 at 10:11:13PM -0400, Wendy Cheng wrote:
> > However, since this particular NLM patch set is only part of the 
> overall
> > scaffolding code to allow NFS V3 server fail over before NFS V4 is
> > widely adopted and stabilized, I'm wondering whether we should drag
> > ourselves too far for something that will be replaced soon.
>
> I don't think that's a valid argument.  We hack this up because it's
> going to be obsolete mid-term never was a really good argument.  And in
> this case it's a particularly bad one.  People won't rush to NFSv4 just
> because someone declares it stable now.  And if they did we couldn't
> simply rip out existing functionality.
>

The "hack" and "bad" are very subjective words in this context. 
Comparing to many other code currently living inside Linux kernel tree, 
this patch set, gone thru 3 rounds of extensive review and discussions, 
deserves at least "average" standing in terms of solution, quality and 
testing efforts.

On the other hand, I certainly welcome further constructive suggestions 
and ideas though.

-- Wendy

 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
