Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:40054 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756375Ab1DYNv3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 09:51:29 -0400
Subject: Re: [PATCH 1/3] NFSv4.1: Don't loop forever in nfs4_proc_create_session
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1303586835.3052.30.camel@lade.trondhjem.org>
Date: Mon, 25 Apr 2011 09:51:17 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <841FDFBB-8E0A-4FF9-A9C9-07AB811B2657@oracle.com>
References: <1303343405-5021-1-git-send-email-Trond.Myklebust@netapp.com> <8912E996-3D52-470F-801B-F37842AB7BF3@oracle.com> <1303586835.3052.30.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 23, 2011, at 3:27 PM, Trond Myklebust wrote:

> On Thu, 2011-04-21 at 11:39 -0400, Chuck Lever wrote:
>> Hi-
>> 
>> This will require some significant human intervention to merge with my code that caches the long-form client ID.
> 
> How so? It really isn't doing much more than removing those 'for(;;)'
> loops.

Essentially the merge of these with my migration patches will not be automatic, because I touch this same code to do long-form client ID caching.  I'm simply pointing out where some effort will be needed as we assemble for-2.6.40.

I'll post my migration patches for review later today, then we can discuss what is needed.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




