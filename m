Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:21136 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757137Ab2ADWje (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 17:39:34 -0500
Subject: Re: [PATCH] NFS: Cache state owners after files are closed
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1325716152.25276.3.camel@lade.trondhjem.org>
Date: Wed, 4 Jan 2012 17:39:29 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <D08F83C3-C3E1-498E-9E82-6C61CB5D9E04@oracle.com>
References: <C0783437-7D8F-4A45-913A-B49692D37AC2@oracle.com> <1325716037-27762-1-git-send-email-Trond.Myklebust@netapp.com> <1325716152.25276.3.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 4, 2012, at 5:29 PM, Trond Myklebust wrote:

> On Wed, 2012-01-04 at 17:27 -0500, Trond Myklebust wrote: 
>> [Trond: Fixed a garbage collection race and a few efficiency issues]
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> As you can see from the resulting patch, I found a couple more
> optimisations: mainly to do with optimising away the dropping and then
> retaking of the client->cl_lock...

Noted.  Good to eliminate more contention on that lock.  I'll try it out.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




