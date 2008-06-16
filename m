From: "howard chen" <howachen@gmail.com>
Subject: Re: [NFS] Sudden high load average and abnormal behavior
Date: Tue, 17 Jun 2008 00:07:59 +0800
Message-ID: <b66ddc900806160907u3f12592dvee46b6dd39516cb9@mail.gmail.com>
References: <b66ddc900806152225o3a7f2bccrf4e83e70c992847a@mail.gmail.com>
	<4856842C.3040807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Wendy Cheng" <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54222 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753971AbYFPQIJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 12:08:09 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K8HFW-0002qd-SD
	for linux-nfs@vger.kernel.org; Tue, 17 Jun 2008 02:08:07 +1000
In-Reply-To: <4856842C.3040807@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

On Mon, Jun 16, 2008 at 11:18 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
> howard chen wrote:
> This will write all the thread backtraces into the system file
> /var/log/messages file so people can have a rough idea of what goes wrong.
> The *trick* here is to make sure the /var/log/messages file doesn't live on
> the particular filesystem that has the high load issue (otherwise the
> writing to the /var/log/messages will hang as well). So you may want to
> configure the /var on a separate filesystem. Remember each ext3 filesystem
> has its own kjournald (again, I have not touched ext3 for a while so this is
> from my old memory).
>
> Another option is to google to see whether other people on the same kernel
> level has the same issue as yours and pull their fix into your system -
> however, it is more of a long shot (since you're doing the guessing).
>
> -- Wendy

Thanks.

I will have a more detail tests

Howard

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

