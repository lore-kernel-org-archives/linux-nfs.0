Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44041 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026Ab1C1IWn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 04:22:43 -0400
Received: by iyb14 with SMTP id 14so2859443iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2011 01:22:42 -0700 (PDT)
Date: Mon, 28 Mar 2011 11:22:20 +0300
From: Dan Carpenter <error27@gmail.com>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: smatch stuff: returning signed values in nfs_negotiate_security()
Message-ID: <20110328082220.GH1885@bicker>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Brian,

7ebb931598 "NFS: use secinfo when crossing mountpoints" has a signed vs
unsigned bug.

fs/nfs/namespace.c +189 nfs_lookup_with_sec(10)
	warn: unsigned 'flavor' is never less than zero.

   161                  page = alloc_page(GFP_KERNEL);
   162                  if (!page) {
   163                          status = -ENOMEM;
				^^^^^^^^^^^^^^^^
	Btw. this gets over written after we goto out.

   164                          goto out;
   165                  }
   166                  flavors = page_address(page);
   167                  status = secinfo(parent->d_inode, &dentry->d_name, flavors);
   168                  flavor = nfs_find_best_sec(flavors, dentry->d_inode);
   169                  put_page(page);
   170          }
   171
   172          return flavor;
   173
   174  out:
   175          status = -ENOMEM;
		^^^^^^^^^^^^^^^^
	Here.

More importantly, the caller is expecting an unsigned return value.  The
check for negative returns in nfs_lookup_with_sec() doesn't work.

   176          return status;

regards,
dan carpenter
