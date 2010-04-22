From: Dennis Nezic <dennisn-YN8wfZw00oOZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Subject: Re: NFS stops responding
Date: Thu, 22 Apr 2010 11:19:07 -0400
Message-ID: <20100422111907.32a1f3a5.dennisn@dennisn.dyndns.org>
References: <4BC62E38.3010704@wsi.com>
	<20100416201700.215b0bea.dennisn@dennisn.dyndns.org>
	<4BCC69E4.70405@wsi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-1dZseelyfdZg9hUCZPvPmw@public.gmane.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:46033 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754885Ab0DVPTX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 11:19:23 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1O4yBT-00043B-J0
	for linux-nfs@vger.kernel.org; Thu, 22 Apr 2010 17:19:19 +0200
Received: from 66.49.244.26 ([66.49.244.26])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 17:19:19 +0200
Received: from dennisn by 66.49.244.26 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 17:19:19 +0200
In-Reply-To: <4BCC69E4.70405-kx56TfycDUc@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hrm, for me the problem seems (so far) to have gone away when I use
"udp" instead of "tcp" with the nfs mount. (Maybe it was related to the
tcp over tcp bad idea, http://sites.inka.de/bigred/devel/tcp-tcp.html )

And, now that I think of it, I was using "udp" originally, and only
recently was forced to use "tcp" due to some bizarre error, which seems
to have resolved itself.

On Mon, 19 Apr 2010 10:34:12 -0400, Michael O'Donnell wrote:
> Well, it's encouraging to finally get a response and even more so that
> you may be seeing the same kinds of failures.  I will post logging
> output from /var/log/messages from the client and server machines
> while the failures are occurring and maybe we can compare notes?
> 
> 
> Dennis Nezic wrote:
> > Well I for one am convinced there is a bug either in the linux
> > kernel, or somewhere. I have a similar problem (I posted about it
> > here on March 18 2010), where NFS activity very frequently hangs
> > for several minutes, for no good reason. (Changing the nfs mount
> > option to "hard" should get rid of the I/O Errors, but it's still
> > incredibly frustrating/annoying
> > -- it will simply retry after precious minutes have been wasted,
> > instead of failing :b). My problems began ONLY after I upgraded my
> > server's kernel. When did yours begin?
> > 
> > I have noticed that when a client hangs, other clients still work --
> > ie. the nfs server is still (sortof) working -- so I imagine there
> > is something wrong with the client too?
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in the body of a message to
> majordomo@vger.kernel.org More majordomo info
> at  http://vger.kernel.org/majordomo-info.html
> 

