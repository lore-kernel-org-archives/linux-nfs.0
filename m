Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:39174 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822Ab3JZRrG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Oct 2013 13:47:06 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Sat, 26 Oct 2013 13:47:05 -0400
In-Reply-To: <OF01D9818B.36018C0F-ON88257C10.00608BC0-88257C10.006139C6@LocalDomain>
References: <1382560643.6924.12.camel@heisenberg.scientia.net> <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com> <1382624000.6907.8.camel@heisenberg.scientia.net> <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com> <1382630468.6907.58.camel@heisenberg.scientia.net> <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com> <1382635350.6907.83.camel@heisenberg.scientia.net> <20131025140846.GB20497@fieldses.org> <526A8D9A.8090008@gmail.com> <7C1323EE-D63F-4F93-A44D-E7DDB0C61BF0@netapp.com> <OF01D9818B.36018C0F-ON88257C10.00608BC0-88257C10.006139C6@LocalDomain>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Dr Fields James Bruce <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org, Wheeler Ric <ricwheeler@gmail.com>
MIME-Version: 1.0
Subject: Re: XATTRs in NFS?
From: Marc Eshel <eshel@us.ibm.com>
Message-ID: <OF7F1977B0.3BF0FF3B-ON88257C10.00618038-88257C10.0061AF59@us.ibm.com>
Date: Sat, 26 Oct 2013 10:46:59 -0700
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

linux-nfs-owner@vger.kernel.org wrote on 10/26/2013 06:20:12 AM:

> I'd rather look bad for not supporting a broken filesystem feature 
> than have to deal with the abiove mentioned side-effects. Until the 
> xattr interface is properly documented and standardised so that it 
> can be exported safely, it should be treated as a unexportable, in 
> the same way we treat procfs and sysfs.
> 

This sounds more like an NFS server problem than a client side NFS. Can we 
add support to the client side NFS and let server that think that they can 
handle XATTR implement it?

We should probably start a discussion in the IETF to resolve the issues 
you see with XATTR at least for NFSv4.3. 

Marc.

> Cheers
>   Trond--


