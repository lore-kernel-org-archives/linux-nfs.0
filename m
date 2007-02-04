From: Neil Brown <neilb@suse.de>
Subject: Re: Please remove getkversion
Date: Mon, 5 Feb 2007 09:35:02 +1100
Message-ID: <17862.24470.588752.234730@notabene.brown>
References: <20070104134504.GA31206@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDpxQ-0007oF-W2
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 14:35:57 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HDpxR-0002hY-Jy
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 14:35:38 -0800
In-Reply-To: message from Steinar H. Gunderson on Thursday January 4
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

On Thursday January 4, sgunderson@bigfoot.com wrote:
> getkversion fails when building against newer kernel headers, since
> UTS_RELEASE is no longer exported to userspace (nor is there any adequate
> replacement that I know of). This has already hit Ubuntu (making nfs-utils
> not build anymore), so they've simply stopped building it -- we're doing so
> in Debian as well, as we'll probably hit the same problems, and getkversion
> isn't really in use anyhow.
> 
> Could we simply remove the tool from upstream git? Is there any known use
> for it?
> 

Sounds fair.  It is removed.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
