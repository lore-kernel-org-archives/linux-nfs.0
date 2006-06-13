From: Amit Gud <gud@eth.net>
Subject: Re: [PATCH 2 / 2] Move NFS mount code from
 util-linux	tonfs-utils - take2
Date: Mon, 12 Jun 2006 23:36:13 -0400
Message-ID: <448E32AD.3070204@eth.net>
References: <448DF3EB.7010601@redhat.com>
	<1150166500.3061.27.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, bunk@stusta.de,
	nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>,
	Amit Gud <agud@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpzeI-00048q-QP
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:33:02 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FpzeI-0003eu-MA
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:33:02 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FpzeH-0000ya-9L
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:33:02 -0700
To: Ian Kent <raven@themaw.net>
In-Reply-To: <1150166500.3061.27.camel@raven.themaw.net>
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

Ian Kent wrote:
> Hi Amit,
> 
> I see that the mtab locking here has the patches that should make it
> work properly (at least I believe that is the case) but if that same fix
> is not implemented in the util-linux code base then the problem will
> persist.
> 
> Perhaps Adrian Bunk should be involved in this since he will ultimately
> need to update util-linux as well?
> 

util-linux already uses this locking protocol (which is included in the 
patches), in fact that code is duplicated now in nfs-utils. But theres 
code like the samba client (mount.cifs), that doesn't follow this and 
have implemented some different mechanism.


AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
