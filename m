From: Neil Brown <neilb@suse.de>
Subject: Re: 2.6.17.6 New(?) NFS Kernel Bug (OOPS) When
	vi	/over/nfs/file.txt
Date: Mon, 4 Sep 2006 22:04:30 +1000
Message-ID: <17660.5710.887383.554921@cse.unsw.edu.au>
References: <Pine.LNX.4.64.0608310708050.2348@p34.internal.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	apiszcz@lucidpixels.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKDC0-0005MY-CE
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 05:04:44 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKDC2-0002jK-NG
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 05:04:47 -0700
To: Justin Piszcz <jpiszcz@lucidpixels.com>
In-Reply-To: message from Justin Piszcz on Thursday August 31
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

On Thursday August 31, jpiszcz@lucidpixels.com wrote:
> Short description: I have a text file I was editing over NFS, around 4 to 
> 5 kilobytes.  It was during this time this occured:
> 
> Note, this is the first time I have ever seen this bug.
> My .config is attached.  After a reboot, I ran the same vi command, no 
> issues, so I could easily reproduce the problem.
> 
> Could anyone offer any insight to exactly what it was that caused this 
> bug?

http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=2f34931fdc78b4895553aaa33748939cc7697c99

This is fixed in a 2.6.17.11 and possibly earlier stable releases.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
