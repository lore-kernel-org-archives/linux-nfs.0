Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:52317 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755069Ab0FKIHM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jun 2010 04:07:12 -0400
Message-ID: <4C11EEAD.8060803@panasas.com>
Date: Fri, 11 Jun 2010 11:07:09 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] LAYOUTGET invocation cleanup patches
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
In-Reply-To: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/11/2010 10:40 AM, Fred Isaman wrote:
> These patches, applied to the head of pnfs-all-latest after rebase, bring
> the blocklayout back in synch with the generic code changed by my previous
> patches and the rebase.  The final tree containing the fully rebased tree
> with these patches applied is at
> git://linux-nfs.org/~isaman/pnfs-block.git in the branch for-benny-20100611.
> 

Grate Fred with a git tree it is actually usable.

I will clone your tree. And'll inspect it carefully on the flight.
I want to do even more. I'd like to rebase them over an Alexandros-less
patchset and actually test them. How hard will that be? Perhaps you
might have a branch based on 2.6.34 without Alexandros patches that
are up to date? Could you push it for me?

> Fred
> 

Thanks
Boaz
