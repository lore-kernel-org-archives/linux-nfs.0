From: Amit Gud <agud@redhat.com>
Subject: Re: [PATCH] Fix NFS mount options in mount.nfs
Date: Fri, 07 Jul 2006 14:03:42 -0400
Message-ID: <44AEA1FE.6080402@redhat.com>
References: <44AE9DC7.4050606@redhat.com> <20060707174542.GA2953@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyucQ-0007CV-0n
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 10:59:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FyucP-0007we-2v
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 10:59:58 -0700
To: "Steinar H. Gunderson" <sesse@debian.org>
In-Reply-To: <20060707174542.GA2953@uio.no>
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
> Thanks, that should clean up most of the problems. How well is this tested?
> 

The problem was the options that are meant solely for the mount utility, 
like remount or noauto, were being passed further down to the syscall. 
These options should be handled within the mount utility only and should 
not be passed further.

I tested with options like 
noauto,async,_netdev,nodiratime,users,dirsync,noatime,nodev,mand,group,owner,suid,user,exec,rw,soft,intr 
and it apparently worked OK. This isn't regressively tested though. I 
would like to see this patch tested in the environment mentioned in 
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=376839 .


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
