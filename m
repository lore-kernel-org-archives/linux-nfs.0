From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] [patch] rpcgen: include sys/ioctl.h on linux systems
Date: Wed, 08 Oct 2008 11:08:07 -0400
Message-ID: <48ECCCD7.4050403@RedHat.com>
References: <200804200649.44542.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:55150 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808AbYJHPLI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 11:11:08 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Knagr-0001sK-96
	for linux-nfs@vger.kernel.org; Thu, 09 Oct 2008 02:11:05 +1100
In-Reply-To: <200804200649.44542.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Mike Frysinger wrote:
> the rpcgen tool included with nfs-utils will generate calls to ioctl()
> but not
> actually generate the sys/ioctl.h header include.  attached patch should
> fix
> this.
> -mike
Committed....

steved.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

