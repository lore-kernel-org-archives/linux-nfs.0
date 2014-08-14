Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gproxy8-pub.mail.unifiedlayer.com ([67.222.33.93]:38950 "HELO
	gproxy8-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751243AbaHNON4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2014 10:13:56 -0400
From: Henrique Martins <linux@martins.cc>
To: Steve Dickson <SteveD@redhat.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils.spec patch
In-reply-to: <53EC7F12.7000608@RedHat.com>
References: <bug-1115179-43722@bugzilla.redhat.com> <bug-1115179-43722-GPTO0t3XWU@bugzilla.redhat.com> <25446.1407076487@monster.martins.cc> <53EB6F3C.2040200@RedHat.com> <12434.1407942499@monster.martins.cc> <53EC7F12.7000608@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 14 Aug 2014 07:13:45 -0700
Message-ID: <30079.1408025625@monster.martins.cc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> but maybe there should be some debate whether to ignore
>> exportfs errors when starting nfs as the default, which
>> just requires adding a couple of '-' to the systemd
>> service file.

> What would be the reasoning? If there is nothing exported
> why come up cleanly?

The "reasoning" is why I filed:
  https://bugzilla.redhat.com/show_bug.cgi?id=1115179
and explained "it" in comment #2
  https://bugzilla.redhat.com/show_bug.cgi?id=1115179#c2

I have a few machines in a laptop's /etc/exports, some only
resolve when I'm connected to the net at work, some only
resolve when I'm connected to the net at home.  With the
default service file nfs always fails to start...

>> A more complicated approach (would require code changes as
>> opposed to configuration changes) would be to not error out
>> if there is at least one exported mount point.

> More complexity than needed... IMHO...

... and thus the need for the complexity to make it clean,
i.e. as long as there is a machine on the particular net I'm
connected to, that can nfs mount the laptop, nfs server
should start and not require me to do some manual editing of
/etc/exports, or write a script to take care of that.

-- Henrique
