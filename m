Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29183 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab2B1FWG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Feb 2012 00:22:06 -0500
Message-ID: <1330406521.9157.16.camel@serendib>
Subject: "Using NFS over UDP on high-speed links such as Gigabit can cause
 silent data corruption."
From: Harshula <harshula@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Date: Tue, 28 Feb 2012 16:22:01 +1100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

The following openSUSE nfs-utils patch, warn-nfs-udp.patch, is not
included upstream:

https://build.opensuse.org/package/view_file?file=warn-nfs-udp.patch&package=nfs-utils&project=openSUSE%3AFactory&rev=8e3e60c70e8270cd4afa036e13f6b2bb

Please consider including it.

Thanks,
#

