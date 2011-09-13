From: <tao.peng@emc.com>
Subject: RE: NULL pointer dereference during mount
Date: Tue, 13 Sep 2011 12:43:21 -0400
Message-ID: <F19688880B763E40B28B2B462677FBF805C3F37B8D@MX09A.corp.emc.com>
References: <F19688880B763E40B28B2B462677FBF805C3299FFE@MX09A.corp.emc.com>,<20110913124202.GA9498@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <bhalevy@tonian.com>, <linux-nfs@vger.kernel.org>
To: <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:25422 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755500Ab1IMQnl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 12:43:41 -0400
In-Reply-To: <20110913124202.GA9498-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


________________________________________
From: Jim Rees [rees@umich.edu]
Sent: Tuesday, September 13, 2011 8:42 PM
To: Peng, Tao
Cc: bhalevy@tonian.com; linux-nfs@vger.kernel.org
Subject: Re: NULL pointer dereference during mount

tao.peng@emc.com wrote:

  After rebasing to your pnfs-all-latest branch, I always got bellow NULL
  pointer dereference for both nfsv4 and pnfs. Do you know of any recent
  change that can cause this?

"git diff" shows no change in the nfs client between my for-benny branch and
benny's pnfs-all-latest branch.  And the mount works for me.  But the first
thing I always do on a fresh Fedora install is disable selinux.  Maybe
something changed in selinux?
[PT] Just tested 3.1-rc6 and it is working properly. So I think it should be caused by nfs changes.