From: Ian Kent <raven@themaw.net>
Subject: Re: [PATCH 2 / 2] Move NFS mount code
	from	util-linux	tonfs-utils - take2
Date: Tue, 13 Jun 2006 21:12:49 +0800
Message-ID: <1150204369.2854.1.camel@raven.themaw.net>
References: <448DF3EB.7010601@redhat.com>
	<1150166500.3061.27.camel@raven.themaw.net> <448E32AD.3070204@eth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, bunk@stusta.de,
	nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>,
	Amit Gud <agud@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fq8hg-0002Hr-Pp
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 06:13:08 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fq8hg-0007l6-QI
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 06:13:08 -0700
Received: from ihug-mail.icp-qv1-irony4.iinet.net.au ([203.59.1.198]
	helo=mail-ihug.icp-qv1-irony4.iinet.net.au)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fq8he-0004Vw-9l
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 06:13:08 -0700
To: Amit Gud <gud@eth.net>
In-Reply-To: <448E32AD.3070204@eth.net>
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

On Mon, 2006-06-12 at 23:36 -0400, Amit Gud wrote:
> Ian Kent wrote:
> > Hi Amit,
> > 
> > I see that the mtab locking here has the patches that should make it
> > work properly (at least I believe that is the case) but if that same fix
> > is not implemented in the util-linux code base then the problem will
> > persist.
> > 
> > Perhaps Adrian Bunk should be involved in this since he will ultimately
> > need to update util-linux as well?
> > 
> 
> util-linux already uses this locking protocol (which is included in the 
> patches), in fact that code is duplicated now in nfs-utils. But theres 
> code like the samba client (mount.cifs), that doesn't follow this and 
> have implemented some different mechanism.

My point is that the code in util-linux does not do the locking properly
and if it is not fixed then the locking here isn't worth anything.

Ian



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
