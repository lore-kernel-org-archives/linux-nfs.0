From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH 6/7] nfs41: implement cb_recall_slot
Date: Thu, 21 Jan 2010 11:33:08 -0500
Message-ID: <4A744F24-CA10-47FE-B7C8-038E75FA5B66@netapp.com>
References: <1264021587-27697-1-git-send-email-andros@netapp.com> <1264022849.7799.4.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
Cc: "Sager, Mike" <Mike.Sager@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41911 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457Ab0AUQdY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2010 11:33:24 -0500
In-Reply-To: <1264022849.7799.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 20, 2010, at 4:27 PM, Trond Myklebust wrote:

> On Wed, 2010-01-20 at 16:06 -0500, andros@netapp.com wrote: 
>> Resend with fix to compile without CONFIG_NFS_V4_1.
>> 
>> Sorry 'bout that Trond.
>> 
>> -->Andy
> 
> No problem. However I did hit a conflict between your patchset and one
> of Mike's. The conflicting patches were
> 
> commit 8f4a598ccfa936dc850323859af8f52bb1ef15c1 nfs41: back channel drc
> minimal implementation
> 
> and
> 
> commit f93f599e8f6f8c26a99beb8324b15bc8c5f3663a nfs41: Process
> callback's referring call list
> 
> 
> Could you please both check that I fixed it up correctly in the
> nfsv41-for-next branch?

Looks correct to me.

-->Andy

> 
> Cheers
>  Trond

