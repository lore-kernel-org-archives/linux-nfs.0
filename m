Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:50265 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022Ab2DQPlU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2012 11:41:20 -0400
Received: by vbbff1 with SMTP id ff1so4249081vbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 08:41:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334611367.2879.59.camel@lade.trondhjem.org>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
	<1334004744-31842-20-git-send-email-iisaman@netapp.com>
	<1334611367.2879.59.camel@lade.trondhjem.org>
Date: Tue, 17 Apr 2012 11:41:18 -0400
Message-ID: <CADnza46tRhuPW6keCOSLkWQ-t9VrLvCUampmCP2aXydTuS=Sdw@mail.gmail.com>
Subject: Re: [PATCH 19/26] NFS: rewrite directio read to use async coalesce code
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 16, 2012 at 5:22 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2012-04-09 at 16:52 -0400, Fred Isaman wrote:
>> This also has the advantage that it allows directio to use pnfs.
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>> -static void nfs_direct_read_release(void *calldata)
>> +static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
>>  {
>> +     unsigned long pos = req_offset(hdr->req);
>
> Umm... req_offset() returns an loff_t. 'unsigned long' is likely to be
> too small to hold these values on a 32-bit machine.
>
> Looking back, it looks as if the same problem exists in the page cache
> code (e.g. nfs_read_completion) as well as stuff like hdr->eof, and
> hdr->first_error.
>
>

OK, I'll fix these.

Fred
