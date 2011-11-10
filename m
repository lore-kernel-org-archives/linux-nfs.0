Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017Ab1KJVch (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Nov 2011 16:32:37 -0500
Message-ID: <4EBC42F4.7080407@RedHat.com>
Date: Thu, 10 Nov 2011 16:32:36 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Enable the in-kernel id mapping to be on by default.
References: <1320956763-17935-1-git-send-email-steved@redhat.com> <1320958342.11956.22.camel@lade.trondhjem.org>
In-Reply-To: <1320958342.11956.22.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/10/2011 03:52 PM, Trond Myklebust wrote:
> On Thu, 2011-11-10 at 15:26 -0500, Steve Dickson wrote: 
>> This patch set enables the in-kernel id mapping upcall
>> mechanism, which will fix deadlocks that can occur 
>> between the rpc.idmapd daemon and the kernel. 
> 
> Which deadlocks are you thinking of?
https://bugzilla.redhat.com/show_bug.cgi?id=730045
https://bugzilla.redhat.com/show_bug.cgi?id=751992
https://bugzilla.redhat.com/show_bug.cgi?id=609252

> 
>> This set also correct the binary name in the kernel 
>> documentation
> 
> Note that we should also at some point change the default value of the
> nfs4_disable_idmapping module parameter. Setting it to 'Y' so that the
> NFS client starts by trying to use numeric u/gids with 'sec=sys' should
> be safe, since we automatically fall back to using string-based
> owner/group names if the server rejects numeric values.
I guess I could look into doing this... 

> 
> Also note that older Linux servers return NFS4ERR_BADNAME in cases where
> they should be using NFS4ERR_BADOWNER: please can distribution
> maintainers make sure that they have applied commit
> f6af99ec1b261e21219d5eba99e3af48fc6c32d4 (nfsd4: name->id mapping should
> fail with BADOWNER not BADNAME).
Dully noted....

steved.
