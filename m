Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lisa.pbhware.com ([96.251.22.156]:9934 "EHLO lisa.pbhware.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725979AbeHWXMx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Aug 2018 19:12:53 -0400
Subject: Re: nfs4-acl-tools 0.3.5
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <20180807193736.GA18187@fieldses.org>
 <20180821165130.GA14413@fieldses.org>
 <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
 <20180822003301.GA17500@fieldses.org>
 <d4649560-ad74-d119-13ba-876af9a4974e@acm.org>
 <20180822151213.GA24172@fieldses.org>
 <c1b05b61-b85e-7dff-8cff-12b85bffb3c6@acm.org>
 <20180822194620.GA25562@fieldses.org>
 <2be55f4f-4c9c-9ee1-72f4-b21e37336b6e@acm.org>
 <20180823143835.GB1019@fieldses.org>
From: "Paul B. Henson" <henson@acm.org>
Message-ID: <470be466-b762-1cf2-83b1-98b535c17909@acm.org>
Date: Thu, 23 Aug 2018 12:41:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180823143835.GB1019@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/23/2018 7:38 AM, J. Bruce Fields wrote:

>> Does something specifically need to be done individually for each
>> file system, or if it supports the standard extended attribute does
>> any file system (including an out of tree file system)
>> automatically function?
> 
> Nothing special's required, it should be automatic.

So if, hypothetically, the NFSv4 server was enhanced to look for and 
understand the standard linux system.nfs4_acl extended attribute, any 
file system, whether in kernel or out of tree, would support exposing 
NFSv4 ACLs via NFS? Even though there's nothing ZFS specific about it, 
that general functionality would not be acceptable for inclusion in the 
mainstream kernel?

That seems a bit of a chicken and egg problem, do you add a feature for 
a subsystem to use so said subsystem could be updated to use it, or you 
update a subsystem to use a feature that doesn't exist yet :)?
