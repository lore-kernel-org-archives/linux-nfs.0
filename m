From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 00/19] RFC add kernel support for newer encrytpion types
Date: Thu, 21 Feb 2008 13:43:46 -0500
Message-ID: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:34672 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbYBUSnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:43:49 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id EF2DF4504
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:43:46 -0500 (EST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Consider this an RFC.

These patches add kernel support for triple-DES and AES encryption to the
Kerberos gss code.

These are currently built on 2.6.25-rc1, but I think they should apply
to the latest code as well.

The first patch adds a crypto cts wrapper to do the cts mode req'd by
AES.  This has been submitted to Herbert Xu.

A couple of things remain:

 - Allocate the blkcipher(s) for "cbc(aes)" during context initialization
   rather than on-demand.  I'll include this in the next version.

 - Add support for rc4-hmac.

 - Implement the code necessary to handle possibly rotated data in the
   version two tokens.  I don't expect we'll see rotated data in normal
   operation, but this should be done for completeness.

There are nfs-utils patches required for the new context format from
user-land to kernel.  I need to finish changes for non-lucid contexts
and test those further.


K.C.
