Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:34854 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab1E1QpF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 May 2011 12:45:05 -0400
Date: Sat, 28 May 2011 12:45:02 -0400
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>, Steve Dickson <SteveD@redhat.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] rpc.mountd: let mountd consult /etc/services for port
Message-ID: <20110528164502.GA9188@merit.edu>
References: <4DAD48C7.9090808@cn.fujitsu.com>
 <4DE0C380.7040608@cn.fujitsu.com>
 <20110528132953.GA8525@merit.edu>
 <D3F4AA10-8A35-4600-815B-D63CB7EF7315@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D3F4AA10-8A35-4600-815B-D63CB7EF7315@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:

  So, we could also address this by getting rid of the legacy RPC behavior
  instead.  However, in cases like this, I typically choose to stick with
  legacy behavior, since that improves backwards compatibility.  It already
  works like this for legacy RPC builds, so in some sense we are stuck with
  it.

Ok.  I remember the earlier discussion but forgot that the patch simply
restores older behavior that was changed by tirpc.  In that case I'll go
along with Mi's patch.
