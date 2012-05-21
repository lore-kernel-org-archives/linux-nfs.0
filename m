Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1337 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752439Ab2EUTDN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 15:03:13 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4LJ3CKQ025071
	for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 12:03:12 -0700 (PDT)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 resend LAYOUTGET on data server invalid
 layout errors
Date: Mon, 21 May 2012 19:03:11 +0000
Message-ID: <79F8EB45-D451-445B-BFA2-800D6FFDDEF4@netapp.com>
References: <1333570957-2008-1-git-send-email-andros@netapp.com>
 <1333570957-2008-2-git-send-email-andros@netapp.com>
 <1337463371.4831.54.camel@lade.trondhjem.org>
In-Reply-To: <1337463371.4831.54.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 19, 2012, at 5:35 PM, Myklebust, Trond wrote:

> On Wed, 2012-04-04 at 16:22 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> The "invalid layout" class of errors is handled by destroying the layout and
>> getting a new layout from the server.  Currently, the layout must be
>> destroyed before a new layout can be obtained.
>> 
>> This means that all references (e.g.lsegs) to the "to be destroyed" layout
>> header must be dropped before it can be destroyed. This in turn means waiting
>> for all in flight RPC's using the old layout as well as draining the data
>> server session slot table wait queue.
>> 
>> Set the NFS_LAYOUT_INVALID flag to redirect I/O to the MDS while waiting for
>> the old layout to be destroyed.
>> 
> 
> Is this patch still of interest? it doesn't seem to apply now that I've
> added your quick failover patches.


Yes - it is still of interest. I'll resend.

-->Andy

> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

