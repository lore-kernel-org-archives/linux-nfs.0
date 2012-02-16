Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:27832 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584Ab2BPUKc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 15:10:32 -0500
Subject: Re: [PATCH 02/13] NFS: Fix comparison signage warnings with slot ID computations
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=windows-1252
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1329421978.4279.23.camel@lade.trondhjem.org>
Date: Thu, 16 Feb 2012 15:10:28 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <B9A69100-91C1-45AE-9542-FFB3DF7D7DA2@oracle.com>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net> <20120215213500.3254.16678.stgit@ellison.1015granger.net> <1329421978.4279.23.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 16, 2012, at 2:52 PM, Myklebust, Trond wrote:

> On Wed, 2012-02-15 at 16:35 -0500, Chuck Lever wrote:
>> To make nfs4proc.c compile cleanly, address the following compiler
>> warnings:
>> 
>> fs/nfs/nfs4proc.c: In function ‘nfs4_free_slot’:
>> fs/nfs/nfs4proc.c:371:2: warning: comparison between signed and
>> 		unsigned integer expressions [-Wsign-compare]
>> fs/nfs/nfs4proc.c: In function ‘nfs4_reset_slot_table’:
>> fs/nfs/nfs4proc.c:5000:15: warning: comparison between signed and
>> 		unsigned integer expressions [-Wsign-compare]
>> fs/nfs/nfs4proc.c: In function ‘nfs4_init_slot_table’:
>> fs/nfs/nfs4proc.c:5064:2: warning: comparison between signed and
>> 		unsigned integer expressions [-Wsign-compare]
>> 
>> Why is max_reqs always u32, but nfs4_slot_table.max_slots a signed
>> integer?
>> 
> 
> There is already a fix for this in the nfs-for-next branch.

I'll drop mine.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




