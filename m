Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713AbbA2BHT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 20:07:19 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t0SE7Pja006609
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 09:07:25 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-58-65.rdu2.redhat.com [10.10.58.65])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t0SE7Oxk020173
	for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 09:07:25 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/4] Configure flag clean up
Date: Wed, 28 Jan 2015 09:07:18 -0500
Message-Id: <1422454042-12840-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are a few patches the change some default values 
and rearrange a few flags as well as added some default
values to flag descriptions.

Question: Does anybody know what this flag came from?
   --enable-kprefix        install progs as rpc.knfsd etc

I can't see where or how it is used? I would like to 
get ride of it.

Also would it cause problems if I enable the linking
of libmount to be on by default?
Basically changing
   --enable-libmount-mount Link mount.nfs with libmount [default=no]
to 
   --disable-libmount-mount Link mount.nfs with libmount [default=no]

Thoughts?

Steve Dickson (4):
  ipv6: Enable IPv6 support by default.
  svcgssd: Disable support for the rpcsec_gss server by default
  configure.ac: clean up
  configure.ac: More clean up

 configure.ac | 41 +++++++++++++++++++++--------------------
 1 file changed, 21 insertions(+), 20 deletions(-)

-- 
2.1.0

