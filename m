From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils - rpc.idmapd - nfsdreopen still broken
Date: Thu, 3 Nov 2005 16:33:43 +1100
Message-ID: <17257.41271.14863.770404@cse.unsw.edu.au>
References: <435FE08F.50204@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EXXjZ-00058n-GF
	for nfs@lists.sourceforge.net; Wed, 02 Nov 2005 21:33:57 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EXXjY-0007XU-55
	for nfs@lists.sourceforge.net; Wed, 02 Nov 2005 21:33:57 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: message from Steve Dickson on Wednesday October 26
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wednesday October 26, SteveD@redhat.com wrote:
> I figured since there is no way of changing these paths or filenames
> by command line args, why not just set them during compile time...
> so that's what this patch does.


Looks good, except that there seems to be some disagreement about
idmap_warnx vs warnx, making the patch not apply cleanly for me,
and the fact that nfsdopenone how has two unused arguments.

I've fixed both of those and committed the change to CVS.

Thanks,

NeilBrown


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
