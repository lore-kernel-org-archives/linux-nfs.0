Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:43197 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab1C2P0W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2011 11:26:22 -0400
Message-ID: <4D91FA1D.1000206@bull.net>
Date: Tue, 29 Mar 2011 17:26:21 +0200
From: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS v4 client blocks when using UDP protocol
References: <EB0F26AF-C0DB-4861-ABB5-72E39CB38090@bull.net> <4D91ED79.4020302@bull.net> <4A05F533-1BE6-4DFC-BC53-9392DA8BED76@oracle.com>
In-Reply-To: <4A05F533-1BE6-4DFC-BC53-9392DA8BED76@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:
> Zoltan-
>
> As far as I know, NFSv4 is not supported on UDP transports.
>Some of it may work, but no warrantee, either expressed or implied, is given.  :-)

Do you mean the Linux implementation?
Because the RFC 3530 speaks about how to do NFS v4 over UDP and UDP6.

Thank you,

Zoltan

