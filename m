Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:35249 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321Ab1IMMmI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 08:42:08 -0400
Date: Tue, 13 Sep 2011 08:42:02 -0400
From: Jim Rees <rees@umich.edu>
To: tao.peng@emc.com
Cc: bhalevy@tonian.com, linux-nfs@vger.kernel.org
Subject: Re: NULL pointer dereference during mount
Message-ID: <20110913124202.GA9498@merit.edu>
References: <F19688880B763E40B28B2B462677FBF805C3299FFE@MX09A.corp.emc.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F19688880B763E40B28B2B462677FBF805C3299FFE@MX09A.corp.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

tao.peng@emc.com wrote:

  After rebasing to your pnfs-all-latest branch, I always got bellow NULL
  pointer dereference for both nfsv4 and pnfs. Do you know of any recent
  change that can cause this?

"git diff" shows no change in the nfs client between my for-benny branch and
benny's pnfs-all-latest branch.  And the mount works for me.  But the first
thing I always do on a fresh Fedora install is disable selinux.  Maybe
something changed in selinux?
