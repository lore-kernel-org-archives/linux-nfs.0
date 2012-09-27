Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20396 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753587Ab2I0SPX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Sep 2012 14:15:23 -0400
Message-ID: <506497B9.3030601@netapp.com>
Date: Thu, 27 Sep 2012 14:15:21 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Joerg Roedel <joerg.roedel@amd.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Joerg Roedel <joro@8bytes.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
References: <20120807134156.GP1996@amd.com> <20120927145217.GA18962@8bytes.org> <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF572@SACEXCMBX04-PRD.hq.netapp.com> <20120927153928.GB18962@8bytes.org> <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF7A3@SACEXCMBX04-PRD.hq.netapp.com> <20120927175623.GG10549@amd.com>
In-Reply-To: <20120927175623.GG10549@amd.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/27/2012 01:56 PM, Joerg Roedel wrote:
> On Thu, Sep 27, 2012 at 04:16:25PM +0000, Myklebust, Trond wrote:
>>> Yes, it contains that commit. I was about to test plain v3.6-rc7 without
>>> my patches (not nfs related, of cource) on-top, but unfortunatly the
>>> disk with the root-fs died :-/
>>> I am about to set up the box again and test plain -rc7.
>>
>> Please do.
> 
> Okay, the box is running again and the bug does not reproduce anymore
> with the new installation. Unfortunatly the old kernel configuration is
> gone together with the previous version of the nfs-utils :-/ I'll try to
> play around with the kernel config a little bit more and see if it
> reproduces again.

Double check that you're using the legacy idmapper, and not the keyring based one (/etc/request-key.conf shouldn't have the "create id_resolver * * /usr/bin/nfsidmap %k %d" line).

- Bryan

> 
> 
> 	Joerg
> 

