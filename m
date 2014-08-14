Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754559AbaHNJTR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2014 05:19:17 -0400
Message-ID: <53EC7F12.7000608@RedHat.com>
Date: Thu, 14 Aug 2014 05:19:14 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Henrique Martins <linux@martins.cc>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils.spec patch
References: <bug-1115179-43722@bugzilla.redhat.com> <bug-1115179-43722-GPTO0t3XWU@bugzilla.redhat.com> <25446.1407076487@monster.martins.cc> <53EB6F3C.2040200@RedHat.com> <12434.1407942499@monster.martins.cc>
In-Reply-To: <12434.1407942499@monster.martins.cc>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/13/2014 11:08 AM, Henrique Martins wrote:
> No rebuild is needed, but maybe there should be some debate
> whether to ignore exportfs errors when starting nfs as the
> default, which just requires adding a couple of '-' to the
> systemd service file.
What would be the reasoning? If there is nothing exported
why come up cleanly?

> 
> A more complicated approach (would require code changes as
> opposed to configuration changes) would be to not error out
> if there is at least one exported mount point.
More complexity than needed... IMHO... 

steved.
