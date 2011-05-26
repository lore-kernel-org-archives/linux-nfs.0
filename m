Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38000 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758251Ab1EZTOr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 15:14:47 -0400
Message-ID: <4DDEA6AB.3050605@panasas.com>
Date: Thu, 26 May 2011 22:14:51 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 25/32] pnfs-obj: report errors and .encode_layoutreturn
 Implementation.
References: <4DDD7392.6040505@panasas.com> <1306358975-17740-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306358975-17740-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/26/2011 12:29 AM, Benny Halevy wrote:
> From: Boaz Harrosh <bharrosh@panasas.com>
> 

Benny here two I'm sending the complete patch because it has conflicts
with previous patches

I'll name it v9

Boaz


> An io_state pre-allocates an error information structure for each
> possible osd-device that might error during IO. When IO is done if all
> was well the io_state is freed. (as today). If the I/O has ended with an
> error, the io_state is queued on a per-layout err_list. When eventually
> encode_layoutreturn() is called, each error is properly encoded on the
> XDR buffer and only then the io_state is removed from err_list and
> de-allocated.
> 
> It is up to the io_engine to fill in the segment that fault and the type
> of osd_error that occurred. By calling objlayout_io_set_result() for
> each failing device.
> 
> In objio_osd:
> * Allocate io-error descriptors space as part of io_state
> * Use generic objlayout error reporting at end of io.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
