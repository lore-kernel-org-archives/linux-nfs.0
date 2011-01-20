Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:26456 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609Ab1ATOGU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 09:06:20 -0500
Content-Type: text/plain; charset=US-ASCII
Subject: RE: Callback slot table overflowed
Date: Thu, 20 Jan 2011 09:01:22 -0500
Message-ID: <7225594ED4A1304C9E43D030A886D221F4C9D8@daytona.int.panasas.com>
References: <20110120030707.GA10667@merit.edu>
From: "Halevy, Benny" <bhalevy@panasas.com>
To: "Jim Rees" <rees@umich.edu>, <linux-nfs@vger.kernel.org>
Cc: "peter honeyman" <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This shouldn't happen as the slot table size is negotiated on session
establishment.  Currently, the client support NFS41_BC_MIN_CALLBACKS (1)
request(s)

Benny


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org on behalf of Jim Rees
Sent: Thu 2011-01-20 05:07
To: linux-nfs@vger.kernel.org
Cc: peter honeyman
Subject: Callback slot table overflowed
 
Is this bad?
Jan 19 21:53:27 pdsi7 kernel: Callback slot table overflowed

All I can tell from the code is that xprt_alloc_bc_request() failed, and the
slots are "preallocated during the backchannel setup".  Is there a hard
limit on these slots?  Where is it set?
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

