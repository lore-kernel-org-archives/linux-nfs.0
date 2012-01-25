Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:49889 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755067Ab2AYJ4z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 04:56:55 -0500
Received: by werb13 with SMTP id b13so3639837wer.19
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jan 2012 01:56:54 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
Date: Wed, 25 Jan 2012 10:56:53 +0100
Message-ID: <CAGue13ozQQ=qn-TqpLF093HbbnZdKAshrhHZ97OSj7u0SDVxng@mail.gmail.com>
Subject: blacklisted DS with pnfs
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

we have observed that in some situations ( probably network glitches )
the pnfs client blacklisted one of the data servers:

NFS: data server 83a95099 connection error -12. Deviceid [22000000000]
marked out of use.

As a result, data server can't be used by this client anymore.

Is there a way to let client to forget about data server?
Some magic in /proc ?

This is SL6.2 (RHEL 6.2):
# uname -a
Linux p3-wgs13 2.6.32-220.2.1.el6.x86_64 #1 SMP Thu Dec 22 11:15:52
CST 2011 x86_64 x86_64 x86_64 GNU/Linux
#

Regards,
   Tigran.
