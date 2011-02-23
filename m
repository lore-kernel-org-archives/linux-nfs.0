Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35119 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620Ab1BWEqI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 23:46:08 -0500
Message-ID: <4D64910E.1030202@panasas.com>
Date: Tue, 22 Feb 2011 20:46:06 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
To: Jim Rees <rees@merit.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: stripe definitions
References: <20110222200558.GC7545@merit.edu>
In-Reply-To: <20110222200558.GC7545@merit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/22/2011 12:05 PM, Jim Rees wrote:
> There's an inconsistency in rfc5663 that had me a bit confused:
> 
>    /// struct pnfs_block_stripe_volume_info4 {
>    ///     length4  bsv_stripe_unit;      /* size of stripe in bytes */
> 
> The comment "size of stripe in bytes" fits the definition of "stripe width"
> from rfc5661 section 13.2, but that's not what's meant here.  The field
> name, "stripe_unit", is correct.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

You are right stripe_unit is the the bytes to write to a single
device before advancing to the next device. The comment is wrong
the "size of stripe in bytes" is stripe_unit * num_of_devices.

The same name used in the OSD and files layout and has the same
meaning.

Cheers
Boaz 
