Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:35721 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756877Ab1FANnV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 09:43:21 -0400
Subject: Re: [PATCH 2/2] lockd: properly convert be32 values in debug messages
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DE6408A.8050105@parallels.com>
Date: Wed, 1 Jun 2011 09:42:22 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <F33ED565-6CD7-4259-B28F-1FEDCC6FAE48@oracle.com>
References: <4DE6408A.8050105@parallels.com>
To: Vasily Averin <vvs@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Vasily-

Please post patches inline, not as attachments.

On Jun 1, 2011, at 9:37 AM, Vasily Averin wrote:

> <diff-sunrpc-debug-20110601-2.txt>

Use be32_to_cpu() or be32_to_cpup(), not ntohl().  Thanks.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




