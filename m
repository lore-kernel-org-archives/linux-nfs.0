From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/27] IPv6 infrastructure for NFS client
Date: Mon, 10 Dec 2007 14:56:16 -0500
Message-ID: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:37299 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbXLJUDp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:03:45 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Here's a patch series to add infrastructure to the in-kernel NFS client to
support AF_INET6 addresses.  I've done some light testing with IPv4 and
text-based mounting to ensure the NFS client continues to work for
supported configurations.

Please consider this series for 2.6.25.

-- 
corporate:    <chuck dot lever at oracle dot com>
