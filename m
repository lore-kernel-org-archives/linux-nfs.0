From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] knfsd: Fix a race in closing NFSd connections.
Date: Wed, 7 Feb 2007 13:09:28 +1100
Message-ID: <17865.13528.750067.168258@notabene.brown>
References: <20070207110636.9166.patches@notabene> <1070207001026.9413@suse.de>
	<20070206175152.39d767dd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, stable@kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HEcG5-0000So-Tc
	for nfs@lists.sourceforge.net; Tue, 06 Feb 2007 18:10:06 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HEcG6-00013j-Hm
	for nfs@lists.sourceforge.net; Tue, 06 Feb 2007 18:10:07 -0800
In-Reply-To: message from Andrew Morton on Tuesday February 6
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

On Tuesday February 6, akpm@linux-foundation.org wrote:
> 
> This patch assumes the presence of
> knfsd-sunrpc-allow-creating-an-rpc-service-without-registering-with-portmapper.patch which
> obviously isn't appropriate for -stable.

Only because they change adjacent lines.  There is no semantic
dependency.
The patch I sent will apply *correctly* against -stable with
"--fuzz=3".
I cannot send a fuzz-free patch if that would make Mr Stable happy.

> 
> Please confirm that the patch which I merged is still OK, thanks.

Yes, the patch which you merged is OK.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
