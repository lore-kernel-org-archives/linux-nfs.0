Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36971 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505Ab2I1NVa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Sep 2012 09:21:30 -0400
Message-ID: <5065A456.4070007@netapp.com>
Date: Fri, 28 Sep 2012 09:21:26 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Joerg Roedel <joro@8bytes.org>
CC: Joerg Roedel <joerg.roedel@amd.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
References: <20120807134156.GP1996@amd.com> <20120927145217.GA18962@8bytes.org> <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF572@SACEXCMBX04-PRD.hq.netapp.com> <20120927153928.GB18962@8bytes.org> <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF7A3@SACEXCMBX04-PRD.hq.netapp.com> <20120927175623.GG10549@amd.com> <506497B9.3030601@netapp.com> <20120928121733.GD18962@8bytes.org>
In-Reply-To: <20120928121733.GD18962@8bytes.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/28/2012 08:17 AM, Joerg Roedel wrote:
> On Thu, Sep 27, 2012 at 02:15:21PM -0400, Bryan Schumaker wrote:
> 
>> Double check that you're using the legacy idmapper, and not the
>> keyring based one (/etc/request-key.conf shouldn't have the "create
>> id_resolver * * /usr/bin/nfsidmap %k %d" line).
> 
> That should only be relevant for NFSv4, no? I am using v3 only (without
> explicitly setting the version as mount option).

Any idmapper problem is only relevant to v4, so if you're seeing a problem that means you're not using NFS v3.

> 
> Anyway, I had no luck on reproducing the failure again after
> re-installation of the box, either with of with-out my patches on-top. I
> tried a few different config settings for NFS too, but the BUG didn't
> trigger again :-/

Maybe it's mounting over v3 now?  Can you retry using "vers=4" in your mount options?

- Bryan

> 
> 
> 	Joerg
> 
> 

