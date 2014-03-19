Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61598 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755729AbaCSRKc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2014 13:10:32 -0400
Message-ID: <5329CF7C.7090308@RedHat.com>
Date: Wed, 19 Mar 2014 13:10:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] SUNRPC: Ensure that call_connect times out correctly
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com>	 <53286A9D.2020007@RedHat.com>	 <362845B0-35A4-4DDF-96F6-42582D66334B@primarydata.com>	 <53288146.4010601@RedHat.com> <1395168308.11244.3.camel@leira.trondhjem.org> <532897DE.6060204@RedHat.com> <EB317FC8-D521-4D80-98D7-FA48B0B9AF0C@primarydata.com> <5329900C.3040200@RedHat.com> <DAF0940D-107D-4251-B00A-DE829A31B36E@primarydata.com> <5329A4B3.20601@RedHat.com> <0C0E5EE2-E7BD-4BE3-961F-3B632B45F026@primarydata.com>
In-Reply-To: <0C0E5EE2-E7BD-4BE3-961F-3B632B45F026@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/19/2014 11:04 AM, Trond Myklebust wrote:
> IOW: there is no way to make mount.nfs honour the ‘retry’ and/or ‘bg' 
> mount options in any consistent fashion by solely relying on kernel timeouts.
I went back and took a look at how bg mounts worked in a number of
older kernels f19(3.12) all the way back to RHEL6 kernel (2.6). 

I turns out you are right. The bg mounts were not depending on
timeouts they were depended on the mount to fail with ECONNREFUSED
The very first one, which is the reason the bg mount happen
so fast... 

Its seems these days ECONNREFUSED are no longer return 
as an error codes. They basically are turned into a 
timeout... Just curious as to why ECONNREFUSED are 
no longer returned?

Again, thanks for the cycles!

steved.
