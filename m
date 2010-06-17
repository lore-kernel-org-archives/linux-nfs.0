Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61280 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754001Ab0FQV4i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 17:56:38 -0400
Message-ID: <4C1A9A1D.1070608@panasas.com>
Date: Thu, 17 Jun 2010 17:56:45 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: andros@netapp.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] pnfs: merge sync and async layoutcommit calls
References: <1276803296-9438-1-git-send-email-andros@netapp.com>
In-Reply-To: <1276803296-9438-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jun. 17, 2010, 15:34 -0400, andros@netapp.com wrote:
> Remove layout driver API calls unused by the file layout.
> 0001-SQUASHME-pnfs-submit-remove-setup_layoutcommit.patch
> 0002-SQUASHNE-pnfs-submit-remove-cleanup_layoutcommit.patch
> 0003-SQUASHME-pnfs-submit-remove-encode_layoutcommit.patch
> 
> 0004-pnfs-submit-merge-sync-and-async-layoutcommit.patch
> 
> Restore the layout API calls for other drivers.
> 0005-pnfs-post-submit-restore-encode_layoutcommit.patch
> 0006-pnfs-post-submit-restore-cleanup_layoutcommit.patch
> 0007-pnfs-post-submit-restore-setup_layoutcommit.patch
> 
> -->Andy
> 
All merged at pnfs-all-2.6.35-rc3-2010-06-17-1

Thanks!

Benny

