Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C643C43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 21:07:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 044A020663
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 21:07:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=samba.org header.i=@samba.org header.b="cjc9C2iJ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726279AbfCFVHv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 16:07:51 -0500
Received: from hr2.samba.org ([144.76.82.148]:26296 "EHLO hr2.samba.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725601AbfCFVHv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 16:07:51 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=samba.org;
         s=42627210; h=Message-ID:Cc:To:From:Date;
        bh=jAKexG1gDt6ADGtZgdb+GxO/N2qKNtu0EkAC1nQy11I=; b=cjc9C2iJlihV8YIKdivgDTZqmf
        lp/dg8Cd7CjLwYH2FsSd0GZ6t+8CaFdbOrJlxaXF0CemSV/1us78g9I+2U5ihHCF3H+xLg0TvvetC
        7B024S1J8pyx1lvVBJtniFmzhlpbHsMWwe9lSSKuPqpVsNUcTNLckAqj8zxP0U8S0CX8=;
Received: from [127.0.0.2] (localhost [127.0.0.1])
        by hr2.samba.org with esmtpsa (TLS1.2:ECDHE_ECDSA_CHACHA20_POLY1305:256)
        (Exim)
        id 1h1dlT-0001bj-6K; Wed, 06 Mar 2019 21:07:47 +0000
Date:   Wed, 6 Mar 2019 13:07:43 -0800
From:   Jeremy Allison <jra@samba.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Amir Goldstein <amir73il@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, samba-technical@lists.samba.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        devel@lists.nfs-ganesha.org
Subject: Re: Better interop for NFS/SMB file share mode/reservation
Message-ID: <20190306210743.GE19279@jra3>
Reply-To: Jeremy Allison <jra@samba.org>
References: <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org>
 <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
 <20190208221239.GA199180@jra3>
 <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
 <20190214210652.GC9216@fieldses.org>
 <20190305214748.GD27437@fieldses.org>
 <20190306151150.GC2426@fieldses.org>
 <1ade4724a4e505baf7b7c23a76e44d58b931da1f.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ade4724a4e505baf7b7c23a76e44d58b931da1f.camel@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 06, 2019 at 03:31:08PM -0500, Jeff Layton wrote:
> On Wed, 2019-03-06 at 10:11 -0500, J. Bruce Fields wrote:
> > On Tue, Mar 05, 2019 at 04:47:48PM -0500, J. Bruce Fields wrote:
> > > On Thu, Feb 14, 2019 at 04:06:52PM -0500, J. Bruce Fields wrote:
> > > > After this:
> > > > 
> > > > 	https://marc.info/?l=linux-nfs&m=154966239918297&w=2
> > > > 
> > > > delegations would no longer conflict with opens from the same tgid.  So
> > > > if your threads all run in the same process and you're willing to manage
> > > > conflicts among your own clients, that should still allow you to do
> > > > multiple opens of the same file without giving up your lease/delegation.
> > > > 
> > > > I'd be curious to know whether that works with Samba's design.
> > > 
> > > Any idea whether that would work?
> > > 
> > > (Easy?  Impossible?  Possible, but realistically the changes required to
> > > Samba would be painful enough that it'd be unlikely to get done?)
> > 
> > Volker reminds me off-list that he'd like to see Ganesha and Samba work
> > out an API in userspace first before commiting to a user<->kernel API.
> > 
> > Jeff, wasn't there some work (on Ceph maybe?) on a userspace delegation
> > API?  Is that close to what's needed?
> > 
> 
> Here's the C headers for that stuff:
> 
>     https://github.com/ceph/ceph/blob/7ba6bece4187eda5d05a9b84211fe6ba8dd287bd/src/include/cephfs/libcephfs.h#L1734
> 
> It's simple enough and works for us in ganesha, and I think we can
> probably adapt it to samba without too much difficulty. The callback
> doesn't seem like it'll do for a kernel API though -- you'd almost
> certainly need to do something different there (signals? inotify?).

SMB3 leases have R/RW and Handle-based leases.

Handle leases allow multiple opens of the same pathname
that get different handles to share the lease, allowing
a client redirector to delay opens or closes locally
so long as it has a handle lease.

Here are the semantics:

https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/d8df943d-6ad7-4b30-9f58-96ae90fc6204

I'm not sure a simple file-descriptor based API is
enough for us. Can he have a uuid or token based
API instead where the server can chose what fd's
to cover with a token ?
