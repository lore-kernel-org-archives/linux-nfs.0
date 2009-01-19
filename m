From: Greg Banks <gnb@sgi.com>
Subject: [patch 0/5] activate & deactivate dprintks individually and severally
Date: Mon, 19 Jan 2009 17:40:18 +1100
Message-ID: <20090119064018.442220000@sgi.com>
Cc: "Frank Ch. Eigler" <fche@redhat.com>
To: Linux NFS ML <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:58544 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752366AbZASGtR (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 01:49:17 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As mentioned in the recent discussion on NFS trace points.

This is a forward ported (from 2.6.16), updated, and split version
of a patch that has been used in SGI's internal development tree for
the last few months.  It's designed to help field support staff and
kernel developers debug kernel problems, by enabling them to treat
dprintks as precise trace points rather than syslog spamming tools.

The very first version of this was used about eighteen months ago
when debugging NFS/RDMA, which has an enormous number of dprintks
and no other way to debug it.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
