Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46982 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab1EWE0U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 00:26:20 -0400
Message-ID: <4DD9E1DA.8030008@panasas.com>
Date: Mon, 23 May 2011 07:26:02 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/13] [RFC] Bugs in new pnfs write path
References: <4DD79273.9030202@panasas.com> <1305973982-17499-1-git-send-email-bharrosh@panasas.com> <4DD9513B.9070003@panasas.com> <4DD9E05E.4070204@panasas.com>
In-Reply-To: <4DD9E05E.4070204@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/23/2011 07:19 AM, Boaz Harrosh wrote:
>>> 3. In pnfs_ld_write_done:
>>>    data->mds_ops->rpc_call_done(NULL, data);
>>>    crashes with a NULL task. Just pass it with &data->task
>>
>> As we don't go through nfs_initiate_write data->task is not initialized.
>> Where's the crash exactly?
>> We better fix it than fake a task structure...
>>

We better do have a valid data->task because we use it all over
in the objects layout driver, to schedule out of the interrupt.

It works fine I tested it

>> Benny

Boaz
