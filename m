Return-Path: linux-nfs-owner@vger.kernel.org
Received: from flmx07.ccur.com ([173.221.59.12]:56790 "EHLO flmx07.ccur.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793AbaAHSKG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jan 2014 13:10:06 -0500
Date: Wed, 8 Jan 2014 13:04:36 -0500
From: Tom Horsley <tom.horsley@ccur.com>
To: <linux-nfs@vger.kernel.org>
Subject: Version negotiation thwarted by proto=udp mount option
Message-ID: <20140108130436.1e7b3157@tomh>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is from redhat bugzilla https://bugzilla.redhat.com/show_bug.cgi?id=1049032

I was asked to send mail here to see what nfs devs think about the problem.

I had the "proto=udp" option on some NFS mount lines in my fstab.
It was there because previous versions of nfs-utils apparently
ceased being able to talk to old servers at one point in time.
This option worked fine and got me connecting to the old servers.

Now a new nfs-utils came along and tries NFSv4 by default
first thing. That always rejects the mount options because
it doesn't support proto=udp at all. This leads the nfs-utils
to error out without trying a different version, so basically
my working fstab ceased to work.

I made it work again by changing to nfsvers=3 instead of
proto=udp. (But nfsvers=3 wasn't working at some point,
which was why I used proto=udp :-).
