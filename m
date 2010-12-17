Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:33751 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602Ab0LQRMF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Dec 2010 12:12:05 -0500
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1292556764.2895.41.camel@heimdal.trondhjem.org>
Date: Fri, 17 Dec 2010 12:11:40 -0500
Cc: Christoph Hellwig <hch@infradead.org>, Ric Wheeler <ricwheeler@gmail.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <3F48F03B-7886-494A-BDC3-AC840991058F@oracle.com>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net> <4D0A6503.7010901@RedHat.com> <20101216230524.GA16760@infradead.org> <4D0AA11A.2010307@gmail.com>  <20101216234058.GA17940@infradead.org> <1292556764.2895.41.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 16, 2010, at 10:32 PM, Trond Myklebust wrote:

> On Thu, 2010-12-16 at 18:40 -0500, Christoph Hellwig wrote:
>> On Thu, Dec 16, 2010 at 06:30:34PM -0500, Ric Wheeler wrote:
>>> This has nothing to do with shame or conspiracy, it has to do with
>>> doing changes in an orderly way so we can test and stabilize things
>>> in the upstream kernel.
>>> 
>>> Changing both at once is not good for upstream or distros  in my opinion,
>> 
>> Steve's mail reads pretty different from that.
>> 
>> But it doesn't really matter as it doesn't make any sense - as Chuck
>> has explained theres zero overlap between the XDR decoder changes and
>> pnfs features anyway.  And if there was it's pretty clear something that
>> the about 98% of the userbase that's using NFSv3 uses should have more
>> priority over the 0.5% that are planning to maybe possibly use pnfs in
>> the next decade.
> 
> Hi guys,
> 
> I agree 100% with the basic premise that we should not have to deal with
> compatibility issues for NFSv4.1/pnfs backports when deciding what to
> merge upstream.
> That said: as far as I can see, pretty much all these changes are
> confined to the NFSv2 and NFSv3 XDR code. I can quite understand why
> distros like Red Hat, SuSE, Debian, and others might want to avoid
> having to back port changes, given that the NFSv2 and NFSv3 code bases
> are supposed to be fully stable and frozen.
> 
> So my questions to Steve and Ric are:
> 
>     1. Specifically, which part of these changes are causing
>        backporting headaches for the RHEL-6 code base? Note that when
>        asking that question I am assuming that Red Hat will triage and
>        reject patches that conflict with their stability goals.
>     2. Could we set up some minimal set of patches that would allow the
>        pNFS backport while avoiding the need for a full backport of
>        Chuck's patches for NFSv2/v3? If so, what features do we need,
>        and what is not needed?
> 
> IOW: how can we refactor these patches so as to avoid tying the set of
> NFSv2/v3 changes to any pNFS interests?

My reading of Ric's concern is that RH doesn't have the resources to deal with bugs in both the pNFS code and the NFSv2/v3 code at the same time.  They would like the ability to ignore orthogonal upstream patches to get the features they want.  I've seen no detailed risk analysis, so I can't confirm that there is significant additional risk to including the XDR patches with the pNFS wave going in 2.6.38.

Practically speaking, RH can safely ignore the NLM changes if they go upstream now, since there ought to be no intersection between pNFS and the NLM changes.  To make the XDR changes ignorable, you could postpone the final two patches in that series until after pNFS is upstream, and there should be few if any merge conflicts with the existing pNFS waves.  But I think those two patches were the reason we wanted to do this change now: we don't want to introduce any more uses of the old XDR API.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




