From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC] NLM lock failover admin interface
Date: Tue, 13 Jun 2006 17:08:13 +1000
Message-ID: <17550.25693.507553.731606@cse.unsw.edu.au>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
	<1150182012.27203.42.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-cluster@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fq30j-0004jC-LX
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 00:08:25 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fq30j-0003hs-OO
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 00:08:25 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fq30i-0004df-B1
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 00:08:25 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: message from Wendy Cheng on Tuesday June 13
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

On Tuesday June 13, wcheng@redhat.com wrote:
> >   One is to register a callback when an interface is shut down.
> >   Another (possibly the best) is to arrange a new signal for lockd
> >   which say "Drop any locks which were sent to IP addresses that are
> >   no longer valid local addresses".
> 
> These, again, give individual filesystem no freedom to adjust what they
> need upon failover. But I'll check them out this week - maybe there are
> good socket layer hooks that I overlook. 
> 

Can you say more about what sort of adjustments an individual filesystem
might want the freedom to make?  It might help me understand the
issues better.

Thanks,
NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
