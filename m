From: Jim Rees <rees@umich.edu>
Subject: Re: (k)ubuntu NFS buy
Date: Fri, 29 Apr 2011 11:02:14 -0400
Message-ID: <20110429150214.GA10040@merit.edu>
References: <4DBABE48.1050901@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jim Anderson <ezjab-EkmVulN54Sk@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:42671 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab1D2PCS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2011 11:02:18 -0400
In-Reply-To: <4DBABE48.1050901-EkmVulN54Sk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Anderson wrote:

  I did a search on the error message and I found the following Ubuntu
  bug: https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/656889
  According to this bug report, This is a bug and it is not fixed in
  10.10 final release.

That's unlikely to be your problem since your server does support tcp.  But
maybe you have a firewall problem.  Try proto=udp and nfsvers=3 mount
options (separately).  If proto=udp works, fix your firewall.
