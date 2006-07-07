From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: [PATCH] Fix NFS mount options in mount.nfs
Date: Fri, 7 Jul 2006 22:32:23 +0200
Message-ID: <20060707203223.GA4193@uio.no>
References: <44AE9DC7.4050606@redhat.com> <20060707184009.GA3338@uio.no>
	<44AEBA34.9080804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fyx0x-0003oy-7H
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 13:33:27 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fyx0w-0007HH-4m
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 13:33:27 -0700
To: Amit Gud <agud@redhat.com>
In-Reply-To: <44AEBA34.9080804@redhat.com>
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

On Fri, Jul 07, 2006 at 03:47:00PM -0400, Amit Gud wrote:
> Please use the attached patch for testing. It varies only in the above 
> portion, but that should make a difference.

Say, why is mount.nfs suid root in the first place? I'd expect it only to be
called by mount, which should be suid already...

/* Steinar */
-- 
Homepage: http://www.sesse.net/

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
