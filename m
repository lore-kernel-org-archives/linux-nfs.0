From: Jim Rees <rees@umich.edu>
Subject: Re: (k)ubuntu NFS bug
Date: Sat, 30 Apr 2011 15:20:38 -0400
Message-ID: <20110430192038.GA2081@merit.edu>
References: <4DBABE48.1050901@ieee.org>
 <20110429150214.GA10040@merit.edu>
 <4DBC5AA0.5090407@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jim Anderson <ezjab-EkmVulN54Sk@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:48588 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907Ab1D3TUn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2011 15:20:43 -0400
In-Reply-To: <4DBC5AA0.5090407-EkmVulN54Sk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Anderson wrote:

  Thank you for the suggestions. If I understood right, I should try:
  
  >>> mount -t nfs duke:/mnt/myFiles /mnt/myFiles -O proto=udp
  and
  >>> mount -t nfs duke:/mnt/myFiles /mnt/myFiles -O nfsvers=3

I'm not sure what that will do but I don't think it's what you want.  Try
these:

mount -o proto=udp duke:/mnt/myFiles /mnt/myFiles
mount -o nfsvers=3 duke:/mnt/myFiles /mnt/myFiles
