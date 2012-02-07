Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:49192 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507Ab2BGPzV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 10:55:21 -0500
Message-ID: <4F31494F.7060201@netapp.com>
Date: Tue, 07 Feb 2012 10:54:55 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFS: Fall back on old idmapper if request_key() fails
References: <1327614865-29322-1-git-send-email-bjschuma@netapp.com> <1328569500.23323.5.camel@lade.trondhjem.org>
In-Reply-To: <1328569500.23323.5.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/06/12 18:05, Myklebust, Trond wrote:

> On Thu, 2012-01-26 at 16:54 -0500, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> This patch removes the CONFIG_NFS_USE_NEW_IDMAPPER compile option.
>> First, the idmapper will attempt to map the id using /sbin/request-key
>> and nfsidmap.  If this fails (if /etc/request-key.conf is not configured
>> properly) then the idmapper will call the legacy code to perform the
>> mapping.  I left a comment stating where the legacy code begins to make
>> it easier for somebody to remove in the future.
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>> I tested this on both Archlinux with nfs-utils 1.2.5 and on Fedora with
>> nfs-utils 1.2.6-rc6.  It did what was expected in both cases.
>>
> 
> It didn't apply on top of the namespace changes. Can you please check if
> my attempt at fixing it up is correct? You'll find it in the 'devel'
> branch of my git repository.


Looks like both patches still work.

- Bryan

> 
> 


