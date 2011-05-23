Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:12380 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755478Ab1EWRua (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 13:50:30 -0400
Message-ID: <4DDA9E62.70103@panasas.com>
Date: Mon, 23 May 2011 20:50:26 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: Boaz Harrosh <bharrosh@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Smack on the head: Questions about pnfs write path
References: <4DD84E8E.5040508@panasas.com>	<4DD855CD.3060901@panasas.com> <BANLkTim30-pDMWTyirSh4uT-C9zJK9XyJg@mail.gmail.com>
In-Reply-To: <BANLkTim30-pDMWTyirSh4uT-C9zJK9XyJg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-23 17:22, Fred Isaman wrote:
> On Sat, May 21, 2011 at 8:16 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 05/22/2011 02:45 AM, Boaz Harrosh wrote:
>>>
>>> Fred git blame points to you:
>>>
>>> What was the meaning of the below code:
>>>
>>
>> OK Smack *ME* on the head
>>
>> A layout driver must have a .pg_test function else
>> that's what happens. pNFS only for a single page.
>> I'd say it should be opposite no?
>>
> 
> Right now, a driver with no pg_test function erroneously misses the
> pnfs_update_layout call in multi-page io.  I'll send a patch to fix
> that shortly.
> 

After discussing this with Trond how about having
pnfs_pageio_init_{read,write} always set
	pgio->pg_test = ld->pg_test

and then let the layout driver initialize its vector to
the generic pnfs_{read,write}_pg_test functions, respectively
if it requires no layout-type specific code.
(and EXPORT_SYMBOL_GPL them for the layout drivers)

Benny

> Fred
