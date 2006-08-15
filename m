From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/22] Hide use of lockd's h_monitored flag
Date: Tue, 15 Aug 2006 16:53:25 +1000
Message-ID: <17633.28517.783973.798394@cse.unsw.edu.au>
References: <20060805130647.GA8024@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCsnw-0005TI-OX
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 23:53:36 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCsnw-0006hb-2E
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 23:53:37 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 624C110056
	for <nfs@lists.sourceforge.net>; Tue, 15 Aug 2006 08:53:30 +0200 (CEST)
To: Olaf Kirch <okir@suse.de>
In-Reply-To: message from Olaf Kirch on Saturday August 5
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

On Saturday August 5, okir@suse.de wrote:
> From: Olaf Kirch <okir@suse.de>
> Subject: Hide use of lockd's h_monitored flag
> 
>   This patch moves all checks of the h_monitored flag into
>   the nsm_monitor/unmonitor functions.
>   A subsequent patch will replace the mechanism by which we
>   mark a host as being monitored.

Something confuses me about this patch too.
You are 'hiding' h_monitored, so I looked and found there was still a
reference to it in clntlock.c - in nlmclnt_prepare_reclaim.  So maybe
it just isn't totally hidden, and this isn't a 'use' but an assignment.

However I looked forward to the patch were you get rid of h_monitored
altogether, moving it into the new nsm_handle, and calling it
sm_monitored, and this assignment then quietly goes away.
I cannot help feeling that you are hiding something here, but I cannot
tell what...

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
