From: Neil Brown <neilb@suse.de>
Subject: Re: NFS randomly denying permission to files
Date: Fri, 2 Feb 2007 12:23:25 +1100
Message-ID: <17858.37517.24831.277303@notabene.brown>
References: <1170369756.1221.8.camel@allingham.power.com>
	<17858.28322.401622.364015@notabene.brown>
	<9DDB513B94253445879B44C250C9BD9A07360F37@venusex1.power.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Don Allingham" <Don.Allingham@dothill.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCn9h-0005cs-V0
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 17:23:58 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HCn9h-0000xM-Gy
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 17:23:59 -0800
In-Reply-To: message from Don Allingham on Thursday February 1
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

On Thursday February 1, Don.Allingham@dothill.com wrote:
> 
> Kernel version for the server and clients are (uname -a):
> 
> Linux vlsi-fs0 2.6.17-10-generic #2 SMP Tue Dec 5 21:16:35 UTC 2006 x86_64 GNU/Linux
> 
> The no_subtree_check option seems to have made a big difference. 

Hmmm... The bug I was thinking of (affected ext3 with dir_index if you
didn't use no_subtree_check) was fixed will before 2.6.17 came out.

What filesystem are you using?  If ext3, what does
  tune2fs -l /dev/XXXX
say (for the device holding the filesystem).

> 
> I'm not familar with tcpdump. However, the new system is on a 1G
> ethernet link, and the old was on a 10/100 link. However, I will
> investigate this if I start seeing the problem again. 

I wouldn't both.  If no_subtree_check fixes it, then tcpdump won't
show us anything interesting.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
