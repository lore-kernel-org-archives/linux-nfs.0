Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:37864 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752410AbeFFPIf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jun 2018 11:08:35 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Fwd: [PATCH v1 0/2] Improve construction of non-UCS
Date: Wed, 6 Jun 2018 11:08:25 -0400
References: <20180604144154.11877.19298.stgit@manet.1015granger.net>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: trond.myklebust@hammerspace.com
Message-Id: <743809C0-9838-4F6F-82E2-073EB4C1543C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

> Begin forwarded message:
> 
> From: Chuck Lever <chuck.lever@oracle.com>
> Subject: [PATCH v1 0/2] Improve construction of non-UCS
> Date: June 4, 2018 at 10:53:23 AM EDT
> To: linux-nfs@vger.kernel.org
> 
> The following series proposes improvements to the default NFSv4.0
> client ID strings. The purpose is to decrease the chance that two
> distinct clients will choose the same string, and to make the same
> client connecting via different transports choose the same string.
> 
> The use of the nodename comes from the NFSv4.1 (uniform) client
> ID string. It has some shortcomings as well, but it is better
> overall than using the client's local address. The use of the
> uniquifier is also copied from the uniform client ID string.
> 
> The goal is to make the default behavior better. Preventing a
> malicious administrator from choosing the same nodename, uniquifier,
> and/or client address on purpose is not possible.
> 
> ---
> 
> Chuck Lever (2):
>      NFSv4.0: Remove cl_ipaddr from non-UCS client ID
>      NFSv4.0: Remove transport protocol name from non-UCS client ID
> 
> 
> fs/nfs/nfs4proc.c |   24 ++++++++++++++++--------
> 1 file changed, 16 insertions(+), 8 deletions(-)

Are you building the official NFS client PR for this merge window?
Would you consider taking this series?


--
Chuck Lever



