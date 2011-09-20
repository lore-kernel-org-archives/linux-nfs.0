Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40732 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957Ab1ITNww (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 09:52:52 -0400
Date: Tue, 20 Sep 2011 09:52:52 -0400
To: =?utf-8?Q?R=C3=BCdiger?= Meier <sweet_f_a@gmx.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: processes hanging in state D when reading from nfs
Message-ID: <20110920135252.GB12422@fieldses.org>
References: <201108272122.53243.sweet_f_a@gmx.de>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <201108272122.53243.sweet_f_a@gmx.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 27, 2011 at 09:22:53PM +0200, Rüdiger Meier wrote:
> I've got an annoying problem with my nfs4 clients.
> Lately I see many processes hanging in state D when reading from nfs
> mount. Sometimes they can be killed sometimes not.

Is this still happening?

> This occurs mostly whith shell scripts started by cron.
> 
> For example on one machine there is a file where suddenly all reads on
> it are hanging, ls -ls still works:
> 
> rwxr-xr-x 1 tk users 128 2010-09-08 15:54 /home/tk/usr/local/scripts/plain_ALLMAJOR.sh
> 
> As you see it's an old script, not modified since long time. It was
> running a few times per day since months.
> 
> Now this is the processlist:
> 
> tk        8829  0.0  0.0  11372   800 ?        Ds   Aug25   0:00 /bin/sh -c ~/usr/local/scripts/plain_ALLMAJOR.sh
> tk        8830  0.0  0.0  11372   824 ?        Ds   Aug25   0:00 /bin/sh -c ~/usr/local/scripts/plain_ALLMAJOR.sh
> tk       18864  0.0  0.0  11372   844 ?        Ds   Aug26   0:00 /bin/sh -c ~/usr/local/scripts/plain_ALLMAJOR.sh
> tk       18865  0.0  0.0  11372   860 ?        Ds   Aug26   0:00 /bin/sh -c ~/usr/local/scripts/plain_ALLMAJOR.sh
> rudi     23745  0.0  0.0  10300   748 pts/20   D    20:39   0:00 file /home/tk/usr/local/scripts/plain_ALLMAJOR.sh
> rudi     24361  0.0  0.0  10300   748 pts/20   D    20:40   0:00 file /home/tk/usr/local/scripts/plain_ALLMAJOR.sh
> root     30417  0.0  0.0  10056   472 ?        D    Aug24   0:00 less /home/tk/usr/local/scripts/plain_ALLMAJOR.sh
> rudi     30569  0.0  0.0  10064  1128 pts/1    D+   20:41   0:00 less /home/tk/usr/local/scripts/plain_ALLMAJOR.sh
> 
> The /bin/sh processes are hanging forever in state "Ds" but can be killed.
> The less and file commands can't be killed.
> On other clients I can read that file without probs.
> 
> The logs on server and clients don't tell me anything.
> What can I do to find out what's the problem?

Running wireshark and watching the network traffic may sometimes give an
idea whether the client or server is to blame.

> BTW each hanging process increases the load by 1 but the affected machines
> are still quite usable even with a load of 800 on a single core CPU!
> 
> 
> here my specs:
> 2.6.37.6-0.7-desktop
> openSUSE 11.4 (x86_64)

On both client and server?

--b.
