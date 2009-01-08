Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:44985 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751848AbZAHI0H (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:07 -0500
Message-Id: <20090108082510.050854000@sgi.com>
Date: Thu, 08 Jan 2009 19:25:10 +1100
From: Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
Subject: [patch 00/14] sunrpc: Sunrpc cache cleanups and upcall rework
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

G'day,

These patches are a snapshot of in-progress work to fix problems with
the sunrpc upcall mechanism which are triggered under load when using
multi-threaded rpc.mountd.  These are currently a hot issue with one
of SGI's customers (SGI PV988959).

The early patches in the series are cleanups with zero logic changes.

The patches have been lightly tested, by mounting and running the
cthon04 tests.  They have not been shipped or used in the field.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
