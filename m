Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63420 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756041Ab0LHUhC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 15:37:02 -0500
Subject: Re: [Bug 24302] Kernel crashes when repeatedly trying to mount nfs share that is failing
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <Chuck.Lever@oracle.com>
In-Reply-To: <1291835010.3067.4.camel@heimdal.trondhjem.org>
Date: Wed, 8 Dec 2010 15:35:39 -0500
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-nfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>, stefan.bader@canonical.com
Message-Id: <3F9D016C-9EDF-4B65-AD77-F225D5F1FA66@oracle.com>
References: <bug-24302-104@https.bugzilla.kernel.org/> <201012081830.oB8IUZ4t027387@demeter2.kernel.org> <1291835010.3067.4.camel@heimdal.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 8, 2010, at 2:03 PM, Trond Myklebust wrote:

> On Wed, 2010-12-08 at 18:30 +0000, bugzilla-daemon@bugzilla.kernel.org
> wrote:
>> https://bugzilla.kernel.org/show_bug.cgi?id=24302
>> 
>> 
>> Andrew Morton <akpm@linux-foundation.org> changed:
>> 
>>           What    |Removed                     |Added
>> ----------------------------------------------------------------------------
>>          Component|Other                       |NFS
>>         AssignedTo|fs_other@kernel-bugs.osdl.o |trond.myklebust@fys.uio.no
>>                   |rg                          |
>> 
>> 
>> 
>> 
>> --- Comment #8 from Andrew Morton <akpm@linux-foundation.org>  2010-12-08 18:30:32 ---
>> OK, I reassigned it to NFS.  If that was wrong then at least the NFS guys
>> should be able to help point things in the right direction.
> 
> <Switching to email interface. Please do not edit the bugzilla entry
> directly, since that will lose the above Cc information>
> 
> 
> Chuck,
> 
> Stefan appears to be hitting a panic in the nfs_umount() call from
> nfs_walk_authlist(). Can you take a look, please?

Recv'd.  I'll have a look.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




