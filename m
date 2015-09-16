Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752750AbbIPTIS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Sep 2015 15:08:18 -0400
Subject: Re: [PATCH v2 0/6] nfsidmap enhancements
To: Chuck Lever <chuck.lever@oracle.com>
References: <20150805143258.13266.92369.stgit@manet.1015granger.net>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <55F9BE20.6030802@RedHat.com>
Date: Wed, 16 Sep 2015 15:08:16 -0400
MIME-Version: 1.0
In-Reply-To: <20150805143258.13266.92369.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/05/2015 10:45 AM, Chuck Lever wrote:
> Add "-d" and "-l" options, and clean up some error handling
> problems.
> 
> I've decided to think more about the mechanism which sets the NFSv4
> domain. Neither conf_ nor libnfsidmap has any support for modifying
> a configuration file. The naive approach is to open-code editing the
> configuration file, which is kind of ugly.
> 
> Build and basic operational testing on Fedora 22 and on RHEL 6
> passes. Steve, IMO these are ready to be merged.
> 
> 
> Changes since the first version:
> - Tested
> - Various small clean ups
> - "else" is gone
> 
> ---
> 
> Chuck Lever (6):
>       nfsidmap: Display the effective NFSv4 domain name
>       nfsidmap: Use find_key_by_type_and_desc() if available
>       nfsidmap: List cached ID mapping results
>       nfsidmap: Fix error handling in id_lookup()
>       nfsidmap: Fix error handling in name_lookup()
>       nfsidmap: Clean up other exit status cases
> 
> 
>  utils/nfsidmap/nfsidmap.c   |  299 ++++++++++++++++++++++++++++++-------------
>  utils/nfsidmap/nfsidmap.man |   74 +++++++++--
>  2 files changed, 271 insertions(+), 102 deletions(-)
All six committed... 

steved.

> 
> --
> Chuck Lever
> 
