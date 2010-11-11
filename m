Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25776 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932211Ab0KKCNh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 21:13:37 -0500
Subject: Re: [PATCH 0/3] Fix session draining and back channel processing 
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <1289484640-4100-1-git-send-email-andros@netapp.com>
Date: Wed, 10 Nov 2010 21:13:35 -0500
Cc: Fred Isaman <iisaman@netapp.com>, NFS list <linux-nfs@vger.kernel.org>
Message-Id: <0B4EC0B1-50B0-4C97-98B9-F8A8E1110BF7@netapp.com>
References: <1289484640-4100-1-git-send-email-andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We need to write tests for the back channel draining. This code passes Cthon, the pynfs session reset tests and cb_layoutrecall tests.

-->Andy

On Nov 11, 2010, at 9:10 AM, andros@netapp.com wrote:

> 
> Currently the state manager only waits for the fore channel to drain.
> The back channel processing must also be considered.
> Have the state manager thread also wait for the any current back channel
> processing to complete (drain).
> 
> Guarantee that the nfs_client exists during callback processing.
> 
> 0001-pnfs-submit-set-back-channel-highest-slot-used.patch
> 0002-pnfs-submit-add-back-channel-draining.patch
> 0003-pnfs-submit-callbacks-cannot-use-an-nfs_client-that-.patch
> 
> -->Andy
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

