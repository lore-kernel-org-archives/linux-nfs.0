Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:37090 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743Ab3GHOsA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jul 2013 10:48:00 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH] Disable NFS version 2
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130705195225.GC8288@fieldses.org>
Date: Mon, 8 Jul 2013 10:47:44 -0400
Cc: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8A32AE41-D3EC-473A-AEB3-664EDA0A4CAC@oracle.com>
References: <1372856675-5520-1-git-send-email-steved@redhat.com> <9A7F190A-2938-4A14-9125-330189DA8597@oracle.com> <51D6AE7D.9070805@RedHat.com> <4408EEAB-97F1-404A-BC58-434729D12364@oracle.com> <20130705195225.GC8288@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 5, 2013, at 3:52 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Fri, Jul 05, 2013 at 10:59:59AM -0400, Chuck Lever wrote:
>> 
>> It feels like we should have a plan for both the server and client.
> 
> That discussion brought out of the woodwork a couple people still
> claiming to depend on v2.  They seemed to only care about the server
> side (because they had some old (non-linux) clients that were still
> using v2 for some reason).
> 
> There could be other cases of people depending on an application tied to
> an obsolete client OS that still expect to be able to upgrade their
> server.
> 
> I may be wrong, but I'd expect the same situation (needing an obsolete
> server to be able to access some data) to be rarer.  (One possible
> exception I noticed is vesta: http://www.vestasys.org/--source-code
> management system with built-in v2-only server.  Wonder if it's still
> alive??)
> 
> Anyway I'm inclined to treat dropping server protocol support by the
> same standard as we'd treat dropping kernel ABI: as in, it's only OK if
> we don't expect anyone to notice.

I'm wondering why this requirement does not also apply to the client.  I've heard the opinion expressed recently that we really should not deprecate a feature that still has users.

It might be reasonable to bring this question up on lkml, specifically in the context of NFS version 2.

For the sake of argument, what would induce us to keep NFSv2 in the client?  Finding someone to maintain it?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




