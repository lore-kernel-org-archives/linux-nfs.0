Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gproxy7-pub.mail.unifiedlayer.com ([70.40.196.235]:44262 "HELO
	gproxy7-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750757AbaHMPIb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2014 11:08:31 -0400
From: Henrique Martins <linux@martins.cc>
To: Steve Dickson <SteveD@redhat.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils.spec patch
In-reply-to: <53EB6F3C.2040200@RedHat.com>
References: <bug-1115179-43722@bugzilla.redhat.com> <bug-1115179-43722-GPTO0t3XWU@bugzilla.redhat.com> <25446.1407076487@monster.martins.cc> <53EB6F3C.2040200@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 13 Aug 2014 08:08:19 -0700
Message-ID: <12434.1407942499@monster.martins.cc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

me> Patch attached, by changing the weekday to match the day
me> number.

steve> Thanks for doing this!!! I definitely appreciated it!!

You're welcome.

steve> I just did the commit on all three branches
steve> (f20,f21,master) but I didn't rebuild anything... If
steve> you need something rebuilt, just let me know...

No rebuild is needed, but maybe there should be some debate
whether to ignore exportfs errors when starting nfs as the
default, which just requires adding a couple of '-' to the
systemd service file.

A more complicated approach (would require code changes as
opposed to configuration changes) would be to not error out
if there is at least one exported mount point.

-- Henrique
