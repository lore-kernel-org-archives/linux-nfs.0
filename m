Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:43280 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758Ab3KYS2S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Nov 2013 13:28:18 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 fix a kswap nfs4_state_manger race
Date: Mon, 25 Nov 2013 18:28:16 +0000
Message-ID: <FFEC0299-5989-4AB1-AB1B-CA1458667D33@netapp.com>
References: <1385402270-14284-1-git-send-email-andros@netapp.com>
 <1385402270-14284-2-git-send-email-andros@netapp.com>
 <5B8C7A9D-CD9E-487A-AC62-B1292649835D@netapp.com>
 <7E331FE8-EF05-434D-8434-0C35C3EF2F8B@netapp.com>
In-Reply-To: <7E331FE8-EF05-434D-8434-0C35C3EF2F8B@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 25, 2013, at 13:17, Adamson, Andy <William.Adamson@netapp.com> wrote:

> 
> On Nov 25, 2013, at 1:13 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
> wrote:
> 
>> 
>> On Nov 25, 2013, at 12:57, <andros@netapp.com> <andros@netapp.com> wrote:
>> 
>>> From: Andy Adamson <andros@netapp.com>
>>> 
>>> The state manager is recovering expired state and recovery OPENs are being
>>> processed. If kswapd is pruning inodes at the same time, a deadlock can occur
>>> when kswapd calls evict_inode on an NFSv4.1 inode with a layout, and the
>>> resultant layoutreturn gets an error that the state mangager is to handle,
>>> causing the layoutreturn to wait on the (NFS client) cl_rpcwaitq.
>>> 
>>> At the same time an open is waiting for the inode deletion to complete in
>>> __wait_on_freeing_inode.
>>> 
>>> If the open is either the open called by the state manager, or an open from
>>> the same open owner that is holding the NFSv4.0 sequence id which causes the
>>> OPEN from the state manager to wait for the sequence id on the Seqid_waitqueue,
>>> then the state is deadlocked with kswapd.
>>> 
>>> Do not handle LAYOUTRETURN errors when called from nfs4_evict_inode.
>> 
>> Why are we waiting for recovery in LAYOUTRETURN at all? Layouts are automatically lost when the server reboots or when the lease is otherwise lost.
>> 
>> IOW: Is there any reason why we need to special-case nfs4_evict_inode? Shouldn’t we just bail out on error in _all_ cases?
> 
> Yeah, I was thinking about this as well - perhaps recovering from session-level errors or grace/delay errors would be useful for the block client.

NFS4ERR_DELAY, probably, yes.

NFS4ERR_GRACE, no… That’s a reboot situation

As for session level errors, I’d say that complicates things too much, since several of those can basically end up masking a NFS4ERR_STALE_CLIENTID error.


Either way, all the layout types (including blocks) should be able to continue on even if we miss a layout return or two. The server has to be coded to expect a forgetful client.

--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

