Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7302 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891Ab1DVJLF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 05:11:05 -0400
Message-ID: <4DB14625.3060403@panasas.com>
Date: Fri, 22 Apr 2011 12:11:01 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [RFC 15/27] pnfs-obj: pnfs_osd XDR definitions
References: <4DAF0DE1.6020609@panasas.com>	 <1303320490-21526-1-git-send-email-bhalevy@panasas.com> <1303332561.23206.52.camel@lade.trondhjem.org>
In-Reply-To: <1303332561.23206.52.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-20 23:49, Trond Myklebust wrote:
> On Wed, 2011-04-20 at 20:28 +0300, Benny Halevy wrote:
>> * Add the pnfs_osd_xdr.h header
>>
>> * defintions the pnfs_osd_layout structure including all it's
>>   sub-types and constants.
>> * Declare the pnfs_osd_xdr_encode/decode_layout API + all needed
>>   inline helpers.
>>
>> * Define the pnfs_osd_deviceaddr structure and all its subtypes and
>>   constants.
>> * Declare API for encoding/decoding of a pnfs_osd_deviceaddr to/from
>>   XDR stream.
>>
>> * Define the pnfs_osd_ioerr structure, its substructures and constants.
>> * Declare API for encoding/decoding of a pnfs_osd_ioerr to/from
>>   XDR stream.
>>
>> * Define the pnfs_osd_layoutupdate structure and its substructures.
>> * Declare API for encoding/decoding of a pnfs_osd_layoutupdate to/from
>>   XDR stream.
>>
>> [Some extra debug-prints]
>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>> [objlayout driver skeleton]
>> [use __be32]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  include/linux/pnfs_osd_xdr.h |  439 ++++++++++++++++++++++++++++++++++++++++++
>>  1 files changed, 439 insertions(+), 0 deletions(-)
>>  create mode 100644 include/linux/pnfs_osd_xdr.h
>>
>> diff --git a/include/linux/pnfs_osd_xdr.h b/include/linux/pnfs_osd_xdr.h
>> new file mode 100644
>> index 0000000..6f2cedf
>> --- /dev/null
>> +++ b/include/linux/pnfs_osd_xdr.h
>> @@ -0,0 +1,439 @@
>> +/*
>> + *  pnfs_osd_xdr.h
>> + *
>> + *  pNFS-osd on-the-wire data structures
>> + *
>> + *  Copyright (C) 2007-2009 Panasas Inc.
>> + *  All rights reserved.
>> + *
>> + *  Benny Halevy <bhalevy@panasas.com>
>> + *
>> + *  This program is free software; you can redistribute it and/or modify
>> + *  it under the terms of the GNU General Public License version 2
>> + *  See the file COPYING included with this distribution for more details.
>> + *
>> + *  Redistribution and use in source and binary forms, with or without
>> + *  modification, are permitted provided that the following conditions
>> + *  are met:
>> + *
>> + *  1. Redistributions of source code must retain the above copyright
>> + *     notice, this list of conditions and the following disclaimer.
>> + *  2. Redistributions in binary form must reproduce the above copyright
>> + *     notice, this list of conditions and the following disclaimer in the
>> + *     documentation and/or other materials provided with the distribution.
>> + *  3. Neither the name of the Panasas company nor the names of its
>> + *     contributors may be used to endorse or promote products derived
>> + *     from this software without specific prior written permission.
>> + *
>> + *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
>> + *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
>> + *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
>> + *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
>> + *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
>> + *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
>> + *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
>> + *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
>> + *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
>> + *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
>> + *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>> + */
>> +#ifndef __PNFS_OSD_XDR_H__
>> +#define __PNFS_OSD_XDR_H__
>> +
>> +#include <linux/nfs_fs.h>
>> +#include <linux/nfs_page.h>
>> +#include <linux/exp_xdr.h>
>> +#include <scsi/osd_protocol.h>
>> +
>> +#define PNFS_OSD_OSDNAME_MAXSIZE 256
>> +
>> +/*
>> + * START OF "GENERIC" DECODE ROUTINES.
>> + *   These may look a little ugly since they are imported from a "generic"
>> + * set of XDR encode/decode routines which are intended to be shared by
>> + * all of our NFSv4 implementations (OpenBSD, MacOS X...).
>> + *
>> + * If the pain of reading these is too great, it should be a straightforward
>> + * task to translate them into Linux-specific versions which are more
>> + * consistent with the style used in NFSv2/v3...
> 
> Please do... We just got rid of these in the NFS code. The last thing we
> want to do is reintroduce them in new code.
> 

Yeah, this is on our queue already
(as mentioned in [RFC 0/27] :)

Benny
