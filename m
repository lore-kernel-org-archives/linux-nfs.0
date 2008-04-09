From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/3] mount.nfs: fix retry option settings with binary
 mount options
Date: Wed, 09 Apr 2008 16:11:29 -0400
Message-ID: <47FD22F1.4030704@RedHat.com>
References: <1206822608-20154-1-git-send-email-jlayton@redhat.com>	<1206822608-20154-2-git-send-email-jlayton@redhat.com>	<47FD0447.9030704@RedHat.com>	<20080409141323.0c594185@barsoom.rdu.redhat.com>	<47FD15FB.6090208@RedHat.com> <20080409153021.3947925b@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756198AbYDIUSO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Apr 2008 16:18:14 -0400
In-Reply-To: <20080409153021.3947925b-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
> 
> Yes. But like I mentioned in the description, there is a potential
> corner case here. If someone does a foreground mount and
> explicitly sets retry=10000 then it will be reset to 2. It's not very
> likely, but is simple enough to prevent...
hmm.. I guess... but programing for every single brain dead
corner case can really make the code more complicated than
it need to be, which I think is the case here... I think I would
rather just added the three lines and live that corner case...

steved.

