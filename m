Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:19769 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757370Ab2FZPOA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2012 11:14:00 -0400
Subject: Re: [PATCH] NFS: Handle authentication errors correctly during lease reclaim
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1340663037.9620.77.camel@lade.trondhjem.org>
Date: Tue, 26 Jun 2012 11:13:55 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <36C1F959-6BA1-479B-9452-4E067514A53A@oracle.com>
References: <20120625204637.1637.14358.stgit@degas.1015granger.net> <1340659210.9620.64.camel@lade.trondhjem.org> <80FBF1AB-7347-4683-9F4E-8FD489641EE0@oracle.com> <1340663037.9620.77.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 25, 2012, at 6:24 PM, Myklebust, Trond wrote:
> On Mon, 2012-06-25 at 17:32 -0400, Chuck Lever wrote:
>> On Jun 25, 2012, at 5:20 PM, Myklebust, Trond wrote:
>>> Why does setting up the nfs_server depend on a successful setclientid
>>> call anyway in the case of minor version 0?
>> 
>> Should this also be the case during trunking discovery?
> 
> I don't see how trunking discovery enters into it. The nfs_server setup
> should not Oops in case of a state initialisation failure.
> 
> However if the user sets the '-omigration' flag, then we should have
> minor version 0 mount wait for trunking discovery to complete, just like
> minor version 1...

The problem is that in current kernels, the authentication failure in my test case occurs in nfs4_get_rootfh().  It's synchronous, in process context, and there is no state recovery activity.

With trunking discovery, the first thing the client does is a SETCLIENTID.  I think the answer here is not to use nfs4_handle_reclaim_lease_error() for trunking detection, since it's design appears to assume that it is running inside the state manager.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com


