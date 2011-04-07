Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43851 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756890Ab1DGUZZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 16:25:25 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: [ANNOUNCE] fedfs-utils for Linux
Date: Thu, 7 Apr 2011 16:24:29 -0400
Message-Id: <AB0460DE-A056-47AA-B387-156D35334E04@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        autofs@linux.kernel.org, util-linux-ng@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Announcing public availability of fedfs-utils for Linux

RFC 5716 introduces the Federated File System (FedFS, for short). FedFS is an extensible standardized mechanism by which system administrators construct a coherent namespace across multiple file servers using file system referrals.

The "fedfs-utils" package is an implementation of the user space components that provide FedFS features on Linux. The package is released under GPL version 2.

The current release is 0.6.1.  This is a very early alpha release for technology preview.  Administrative, programming, and command line interfaces will change as this package evolves, and must not be relied on.

See http://oss.oracle.com/projects/fedfs-utils for more information and source code downloads.  Two mailman mailing lists are also available:

  fedfs-utils-announce@oss.oracle.com
  fedfs-utils-devel@oss.oracle.com

Future release announcements will occur only on fedfs-utils-announce.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




