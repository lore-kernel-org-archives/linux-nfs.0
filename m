From: Amit Gud <agud@redhat.com>
Subject: Re: [PATCH] Fix NFS mount options in mount.nfs
Date: Fri, 07 Jul 2006 16:54:09 -0400
Message-ID: <44AEC9F1.6000804@redhat.com>
References: <44AE9DC7.4050606@redhat.com> <20060707184009.GA3338@uio.no>
	<44AEBA34.9080804@redhat.com> <20060707203223.GA4193@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyxHS-0005By-7T
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 13:50:30 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FyxHR-0002mC-AJ
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 13:50:30 -0700
To: "Steinar H. Gunderson" <sesse@debian.org>
In-Reply-To: <20060707203223.GA4193@uio.no>
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

Steinar H. Gunderson wrote:
> On Fri, Jul 07, 2006 at 03:47:00PM -0400, Amit Gud wrote:
>> Please use the attached patch for testing. It varies only in the above 
>> portion, but that should make a difference.
> 
> Say, why is mount.nfs suid root in the first place? I'd expect it only to be
> called by mount, which should be suid already...
> 

For security reasons, mount command resets the uids before calling 
mount.nfs. So, even mount.nfs needs to be suid root to be able to use 
the 'user' and 'users' mount options for NFS.


AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
