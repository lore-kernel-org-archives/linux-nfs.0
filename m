From: Ian Kent <raven@themaw.net>
Subject: Re: [PATCH 2 / 2] Move NFS mount code from util-linux
	to	nfs-utils - take2
Date: Tue, 13 Jun 2006 10:41:40 +0800
Message-ID: <1150166500.3061.27.camel@raven.themaw.net>
References: <448DF3EB.7010601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Amit Gud <gud@eth.net>,
	nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fpyqk-0008M9-HU
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 19:41:50 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fpyqk-000830-GD
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 19:41:50 -0700
Received: from customer-domains.icp-qv1-irony8.iinet.net.au ([203.59.1.133])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fpyqj-0007mT-8W
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 19:41:50 -0700
To: Amit Gud <agud@redhat.com>
In-Reply-To: <448DF3EB.7010601@redhat.com>
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


Hi Amit,

I see that the mtab locking here has the patches that should make it
work properly (at least I believe that is the case) but if that same fix
is not implemented in the util-linux code base then the problem will
persist.

Perhaps Adrian Bunk should be involved in this since he will ultimately
need to update util-linux as well?

Ian



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
