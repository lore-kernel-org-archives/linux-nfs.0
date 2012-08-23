Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:34212 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933721Ab2HWKpc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Aug 2012 06:45:32 -0400
Message-ID: <503609BF.60809@panasas.com>
Date: Thu, 23 Aug 2012 13:45:19 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Dick Streefland <dick.streefland@altium.nl>
CC: <rnews@altium.nl>, <linux-nfs@vger.kernel.org>
Subject: Re: NFSv3 client hang on many simultanious reads
References: <4d25.5034e746.eefd1@altium.nl>
In-Reply-To: <4d25.5034e746.eefd1@altium.nl>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/22/2012 05:05 PM, Dick Streefland wrote:
<>

> 
> The client kernel version is 3.4.7, but the problem also exists in 3.1
> kernels. I cannot reproduce lockups with a 3.0 kernel. The server is
> running Linux 3.1.4. The mount options from /proc/mounts are:
> 


It seems from above that the problem was introduced between 3.0
and 3.1.

Would it be at all possible for you to do a "git bisect" between
3.0 and 3.1 to Identify the bad commit that introduced this problem?

Thanks in advance
Boaz
