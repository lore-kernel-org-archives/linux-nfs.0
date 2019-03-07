Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0666AC43381
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 16:47:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A28F120840
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 16:47:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=samba.org header.i=@samba.org header.b="Qig7+jMI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726214AbfCGQrm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 11:47:42 -0500
Received: from hr2.samba.org ([144.76.82.148]:23332 "EHLO hr2.samba.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726194AbfCGQrm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Mar 2019 11:47:42 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=samba.org;
         s=42627210; h=Date:Cc:To:From:Message-ID;
        bh=pHqPTPwKZ1fwDv5SJA3DrynjRyPl3WyfHXsxb8Y0KJ8=; b=Qig7+jMIlziM1h6VLaS26cbTwW
        eWfKU3NtuFKOQzBt3DnVq7jONyp4VKImg2WCtXyMzskwa+4jyloTtixnl8XaWaZM9jLt5PjZTBIrG
        msxgPgloZJrzGvqUUrH7XbzFvC3NL4q/yrVoeSg/1Uep7TQI3cclVE+iMqvjFCiNZgvw=;
Received: from [127.0.0.2] (localhost [127.0.0.1])
        by hr2.samba.org with esmtpsa (TLS1.2:ECDHE_ECDSA_CHACHA20_POLY1305:256)
        (Exim)
        id 1h1wBG-0000zq-5S; Thu, 07 Mar 2019 16:47:38 +0000
Message-ID: <9382c15297ec44bd5d5d914b68655c5519c9a77b.camel@samba.org>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
From:   Simo <simo@samba.org>
To:     Stefan Metzmacher <metze@samba.org>,
        Ralph =?ISO-8859-1?Q?B=F6hme?= <slow@samba.org>,
        Jeremy Allison <jra@samba.org>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, devel@lists.nfs-ganesha.org,
        Jeff Layton <jlayton@kernel.org>,
        Amir Goldstein <amir73il@gmail.com>,
        samba-technical <samba-technical@lists.samba.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Date:   Thu, 07 Mar 2019 11:47:35 -0500
In-Reply-To: <5ebdb58b-26d9-c0f2-bd67-883bc4678ac7@samba.org>
References: <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
         <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
         <20190208155052.GB20573@fieldses.org>
         <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
         <20190208221239.GA199180@jra3>
         <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
         <20190214210652.GC9216@fieldses.org> <20190305214748.GD27437@fieldses.org>
         <20190306151150.GC2426@fieldses.org>
         <1ade4724a4e505baf7b7c23a76e44d58b931da1f.camel@kernel.org>
         <20190306210743.GE19279@jra3>
         <F00A0481-0AC7-411E-8353-BF104713F524@samba.org>
         <5ebdb58b-26d9-c0f2-bd67-883bc4678ac7@samba.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 2019-03-07 at 12:03 +0100, Stefan Metzmacher via samba-
technical wrote:
> Am 06.03.19 um 22:25 schrieb Ralph Böhme via samba-technical:
> > Jeremy Allison wrote:
> > > On Wed, Mar 06, 2019 at 03:31:08PM -0500, Jeff Layton wrote:
> > > > On Wed, 2019-03-06 at 10:11 -0500, J. Bruce Fields wrote:
> > > > > Jeff, wasn't there some work (on Ceph maybe?) on a userspace delegation
> > > > > API?  Is that close to what's needed?
> > > > > 
> > > > 
> > > > Here's the C headers for that stuff:
> > > > 
> > > >    https://github.com/ceph/ceph/blob/7ba6bece4187eda5d05a9b84211fe6ba8dd287bd/src/include/cephfs/libcephfs.h#L1734
> > > > 
> > > > It's simple enough and works for us in ganesha, and I think we can
> > > > probably adapt it to samba without too much difficulty. The callback
> > > > doesn't seem like it'll do for a kernel API though -- you'd almost
> > > > certainly need to do something different there (signals? inotify?).
> > > 
> > > SMB3 leases have R/RW and Handle-based leases.
> > 
> > Just to be precise: SMB2.1+ has R, RH, RW and RWH leases.
> > 
> > > Handle leases allow multiple opens of the same pathname
> > > that get different handles to share the lease, allowing
> > > a client redirector to delay opens or closes locally
> > > so long as it has a handle lease.
> > 
> > That'a a propertly of leases in general, not just H-leases. The client provides a lease key which is a GUID with each lease request
> > 
> > > Here are the semantics:
> > > 
> > > https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/d8df943d-6ad7-4b30-9f58-96ae90fc6204
> > > 
> > > I'm not sure a simple file-descriptor based API is
> > > enough for us. Can he have a uuid or token based
> > > API instead where the server can chose what fd's
> > > to cover with a token ?
> > 
> > Yes, that would be ideal.
> 
> If we want to design an useful API, we also need to think about
> all features:
> - file oplock/leases
> - directory leases
> - share modes
> - disconnected handles (for durable and persistent handles),
>   which exists within the kernel for a while and can be reattached
>   to process, using some kind of cookie and the same euid
> - the API needs ways to use epoll in order to do async opens
>   and lease breaks. For opens the model of async socket connects
>   could be used. Leases could have a signalfd-style api.
> 
> We may not need everything at once, but we should have the full picture
> in mind. And we need working code in kernel and userspace that passes
> all tests (we may need to add additional test). Otherwise the kernel
> creates new syscalls, which wouldn't be used by Samba in the end.

Just a thought, but you should probably classify these facilities in
two lists, one for items that can only reasonably be done via a kernel
API and one for items that can be satisfactorily be handled via a
coordinating userspace component (daemon/database/convention/other).

Getting all that stuff in kernel may prove overly hard and contentious
so being able to negotiate on the critical items only may be important.

Simo.


