Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13693 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756140Ab1EWSUe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 14:20:34 -0400
Message-ID: <4DDAA55C.7030700@panasas.com>
Date: Mon, 23 May 2011 21:20:12 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCHSET v6 0/26] pnfs for 2.6.40
References: <4DDA8C3D.5080706@panasas.com>
In-Reply-To: <4DDA8C3D.5080706@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/23/2011 07:33 PM, Benny Halevy wrote:
> Hi,
> 
> This is a cleaned up version of the v5 patchset I sent earlier.
> It's also based over v2.6.39 and push to
> git://linux-nfs.org/~bhalevy/linux-pnfs.git pnfs-submit
> at tag pnfs-for-2.6.40-v6-2011-05-23
> 
> Changes in v6: (Benny)
> * squashed all SQUASHMEs
> * reverted "SQUASHME: initialize data->task on the non-rpc io done
> success paths"
> * reverted "per mount layout driver private data"
> * reverted "pnfs: set/unset layoutdriver"
> * applied (in reverse) "SQUASHME: pnfs-obj: Important fallout from the
> last rebase"
> 
<snip>

Benny I found some more small bugs. Do you want a full replacement patch
or a SQUASHME?

Boaz
 
