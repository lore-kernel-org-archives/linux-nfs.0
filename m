Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:52179 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399AbbAQSZ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Jan 2015 13:25:28 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1YCY3m-000618-K6
	for linux-nfs@vger.kernel.org; Sat, 17 Jan 2015 19:25:22 +0100
Received: from p4ff586bf.dip0.t-ipconnect.de ([79.245.134.191])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 17 Jan 2015 19:25:22 +0100
Received: from holger.hoffstaette by p4ff586bf.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 17 Jan 2015 19:25:22 +0100
To: linux-nfs@vger.kernel.org
From: Holger =?iso-8859-1?q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: nfs-utils/idmapd: use of private define breaks with libevent-2.1.x
Date: Sat, 17 Jan 2015 18:25:17 +0000 (UTC)
Message-ID: <pan.2015.01.17.18.25.17@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hello,

The Gentoo community has found a problem with the current release of
nfs-utils, where idmapd uses a not strictly private, yet strongly
discouraged #define.

Bug description with proposed patch:
https://bugs.gentoo.org/show_bug.cgi?id=446374

The code in question:
http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=blob;f=utils/idmapd/idmapd.c;hb=HEAD#l719 

According to:
https://github.com/libevent/libevent/blob/master/include/event2/event_struct.h

which says:
"No field declared in this file should be used directly in user code."

using EVLIST_INIT directly is bound to break. This seems to be a leftover
from legacy code.

A simple fix is attached to the bugzilla above and just calls the
proper public API, which is functionally equivalent to the bit check.

Would be nice to see this in 1.3.2. :)

Thanks!

Holger

