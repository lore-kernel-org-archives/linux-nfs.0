Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:57951 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034Ab1HJP7v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 11:59:51 -0400
Date: Wed, 10 Aug 2011 11:59:50 -0400
From: Jim Rees <rees@umich.edu>
To: Peng Tao <bergwolf@gmail.com>
Cc: Benny Halevy <benny@tonian.com>, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH 4/5] SUNRPC/NFS: make rpc pipe upcall generic
Message-ID: <20110810155950.GA4472@merit.edu>
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com>
 <1312685635-1593-4-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1312685635-1593-4-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Peng Tao wrote:

  The same function is used by idmap, gss and blocklayout code. Make it
  generic.

Thank you.  That one bothered me (see comment) but I didn't have time to
take care of it during the merge.
