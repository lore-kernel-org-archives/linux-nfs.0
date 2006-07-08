From: Amit Gud <agud@redhat.com>
Subject: Re: [PATCH] Fix NFS mount options in mount.nfs
Date: Sat, 08 Jul 2006 15:12:26 -0400
Message-ID: <44B0039A.2050501@redhat.com>
References: <44AE9DC7.4050606@redhat.com> <20060707174542.GA2953@uio.no>	
	<44AEA1FE.6080402@redhat.com>
	<76bd70e30607081156u75d8bd28oda7432eab6d82c5d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>,
	"Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FzIAS-0006FG-36
	for nfs@lists.sourceforge.net; Sat, 08 Jul 2006 12:08:40 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FzIAQ-0005JV-3A
	for nfs@lists.sourceforge.net; Sat, 08 Jul 2006 12:08:40 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30607081156u75d8bd28oda7432eab6d82c5d@mail.gmail.com>
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

Chuck Lever wrote:
> 
> How does this change affect the mount options that show up in
> /proc/mounts and /proc/self/mountstats?

IMO, it wouldn't affect at all. We are just trying to change the 
user-space binaries, the stuff going in the kernel is still the same.


AG--
May the source be with you.
http://www.cis.ksu.edu/~gud


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
