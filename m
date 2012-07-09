Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:39389 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722Ab2GITwE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2012 15:52:04 -0400
Subject: Re: [PATCH 01/14] NFS: Clean up TEST_STATEID and FREE_STATEID proc error reporting
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1341862560.15267.3.camel@lade.trondhjem.org>
Date: Mon, 9 Jul 2012 15:51:57 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <69150A39-D865-43CC-8068-B3A4161F5ABD@oracle.com>
References: <20120709153355.1604.14102.stgit@degas.1015granger.net> <20120709154349.1604.58109.stgit@degas.1015granger.net> <1341862560.15267.3.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 9, 2012, at 3:36 PM, Myklebust, Trond wrote:

> On Mon, 2012-07-09 at 11:43 -0400, Chuck Lever wrote:
>> The TEST_STATEID and FREE_STATEID operations can return
>> NFS4ERR_BAD_STATEID, NFS4ERR_OLD_STATEID, or NFS4ERR_DEADSESSION.
>> These error values should not be passed to nfs4_handle_exception(),
>> since that will recursively kick off state recovery, resulting in a
>> deadlock.  The reason to continue using nfs4_handle_exception() is
>> to deal with NFS4ERR_DELAY.
>> 
>> Moreover, specifically when the TEST_STATEID operation returns
>> NFS4_OK, res.status can contain one of these errors.
>> _nfs41_test_stateid() replaces NFS4_OK with the value in res.status,
>> which is then returned to callers.
>> 
>> But res.status is not passed through nfs4_stat_to_errno(), and thus is
>> a positive NFS4ERR value.  Currently callers are only interested in
>> !NFS4_OK, and nfs4_handle_exception() ignores positive values, so this
>> oversight hasn't bitten us so far.
>> 
>> Bryan agrees the original intent was to return res.status as a
>> negative NFS4ERR value to callers of nfs41_test_stateid(), as long as
>> no state ID recovery is attempted.
> 
> None of this describes a cleanup... AFAICS it is all a bugfix

IIRC behavior isn't supposed to change, so I don't think this should go to -stable.  The subsequent patches rely on the error path being corrected, though.

>> As a finishing touch, add appropriate documenting comments and some
>> debugging printk's.
> 
> This should be a separate patch so that we can send the bugfix part to
> stable@vger if needed...

I can redrive as two patches, but we should be careful about back porting, IMO.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




