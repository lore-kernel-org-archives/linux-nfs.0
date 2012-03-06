Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19399 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030775Ab2CFPNj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 10:13:39 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4.1: Fix the checking of the stateid when
 returning a delegation
Date: Tue, 6 Mar 2012 15:13:37 +0000
Message-ID: <0A25AB17-8DC0-4524-A276-2BB1B80348C5@netapp.com>
References: <1331045205-3031-1-git-send-email-andros@netapp.com>
 <1331045205-3031-2-git-send-email-andros@netapp.com>
 <1331045839.3260.8.camel@lade.trondhjem.org>
In-Reply-To: <1331045839.3260.8.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2012, at 9:57 AM, Myklebust, Trond wrote:

> On Tue, 2012-03-06 at 09:46 -0500, andros@netapp.com wrote:
>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>> 
>> nfs41_validate_delegation_stateid is broken if we supply a stateid with
>> a non-zero sequence id. Instead of trying to match the sequence id,
>> the function assumes that we always want to error. While this is
>> true for a delegation callback, it is not true in general.
>> 
>> Also fix a typo in nfs4_callback_recall.
>> 
>> Reported-by: Andy Adamson <andros@netapp.com>
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Did you really intend to Cc: stable on these before we've committed them
> upstream?

I guess I misunderstood when to add the Cc: stable.

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

