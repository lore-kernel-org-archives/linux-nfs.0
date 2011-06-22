Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:63558 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722Ab1FVPbf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 11:31:35 -0400
Received: by vxb39 with SMTP id 39so670993vxb.19
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2011 08:31:34 -0700 (PDT)
Date: Wed, 22 Jun 2011 11:31:34 -0400
Message-ID: <BANLkTi=9pcp+bXTx5p+K2Y7NxgFv9iu_6w@mail.gmail.com>
Subject: libgssglue-0.3 now available
From: Kevin Coffman <kwc@citi.umich.edu>
To: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

A new version of library libgssglue is now available from:

http://www.citi.umich.edu/projects/nfsv4/linux/libgssglue/libgssglue-0.3.tar.gz

Changes since libgssglue-0.2:

    	* Add new typedefs defined in RFC 5587 and used
	  in newer versions of MIT Kerberos.  Fixes a
	  compile error in nfs-utils which uses gssapi.h
	  from this package and other gss headers from the
	  Kerberos distribution.
