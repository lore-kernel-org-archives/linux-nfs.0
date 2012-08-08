Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7434 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758723Ab2HHPZT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 11:25:19 -0400
Message-ID: <502284DD.3030004@netapp.com>
Date: Wed, 08 Aug 2012 11:25:17 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs4 mounts failing with 3.6.0-rc1
References: <20120804000819.GB25558@fieldses.org>    <20120803220039.743fe1f0@corrin.poochiereds.net>    <20120804190104.GA2135@fieldses.org>    <20120807130932.79625d7e@tlielax.poochiereds.net>    <20120807194250.GB22532@fieldses.org> <50217035.5010304@netapp.com>    <20120807195703.GC22532@fieldses.org> <50217649.6010402@netapp.com>    <20120807202523.GD22532@fieldses.org>   <1344374613.8845.3.camel@lade.trondhjem.org> <50227AE9.2020600@netapp.com>  <1344438488.3423.9.camel@lade.trondhjem.org> <5022829A.3040209@netapp.com> <1344439438.3423.11.camel@lade.trondhjem.org>
In-Reply-To: <1344439438.3423.11.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/08/2012 11:24 AM, Myklebust, Trond wrote:
> On Wed, 2012-08-08 at 11:15 -0400, Bryan Schumaker wrote:
>> On 08/08/2012 11:08 AM, Myklebust, Trond wrote:
>>> On Wed, 2012-08-08 at 10:42 -0400, Bryan Schumaker wrote:
>>>> So you're suggesting something like this?  I can split it into two patches for the final submission, one to rename the modules and one to move the nfs4_fs_type back to nfs.ko.
>>>
>>> One patch should suffice, since you can't split this up into something
>>> that fixes both issues.
>>>
>>> Then maybe we can add a separate patch with a MODULE_ALIAS("nfs4") so
>>> that distros can start removing the /etc/modprobe.conf alias entries.
>>
>> Sure.  That goes in the v4 module?
> 
> No. The nfs module, since that is what calls register_nfs4_fs()...
> 

Ok.  I'm testing patch 1 now, I'll add in the alias next.

- Bryan
