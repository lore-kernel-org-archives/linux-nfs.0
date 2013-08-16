Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport01-1.csupomona.edu ([134.71.187.41]:47922 "EHLO
	ironport01-1.csupomona.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753055Ab3HPBlA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Aug 2013 21:41:00 -0400
Date: Thu, 15 Aug 2013 18:40:58 -0700
From: Brian De Wolf <bldewolf@csupomona.edu>
To: Bryan Schumaker <bjschuma@gmail.com>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: NFS uses wrong domain in SETATTR
Message-ID: <20130815184058.4c5eb4c4@csupomona.edu>
In-Reply-To: <520D0F23.5070201@gmail.com>
References: <20130718174155.0f189280@csupomona.edu>
	<52015795.9060003@gmail.com>
	<20130806195327.71323541@csupomona.edu>
	<520D0F23.5070201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 15 Aug 2013 10:25:55 -0700
Bryan Schumaker <bjschuma@gmail.com> wrote:

> Have you made sure to reboot or restart idmapd after making changes
> to /etc/idmap.conf?  The only time I've been able to reproduce this
> is when the config file has been changed but not reloaded.
> 

Well, I finally dove into libnfsidmap and nfs-utils and tracked it down
to a bug in nfs-utils.  Sorry, I should have said we were still on
nfs-utils-1.2.6, which seems to be pretty old by now.  This looks like
the commit that fixed it:

http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=fd27c638898010438d404cd17120729ef1d680e2

This change is in 1.2.7 and, after upgrading to it on my test box,
chgrp works once again.  Sorry for the noise, I should have tried
upgrading nfs-utils first (at least I know a lot about the new idmapper
now!).

Thanks for the help,
Brian
