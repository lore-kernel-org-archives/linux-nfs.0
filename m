Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13339 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755020Ab3JXPLl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 11:11:41 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: Christoph Anton Mitterer <calestyo@scientia.net>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: XATTRs in NFS?
Date: Thu, 24 Oct 2013 15:11:39 +0000
Message-ID: <1382627496.6430.2.camel@leira.trondhjem.org>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
	 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
	 <1382624000.6907.8.camel@heisenberg.scientia.net>
	 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
	 <1382627225.899.76.camel@willson.li.ssimo.org>
In-Reply-To: <1382627225.899.76.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-24 at 11:07 -0400, Simo Sorce wrote:

+AD4- Because the filesystem can do that when multiple applications are
+AD4- involved without having to change them all to talk to each other and
+AD4- invent custom protocol all the time just to keep some additional
+AD4- metadata associated to a file..
+AD4- 
It's still a custom protocol. The applications need to agree on a data
format and store it somewhere. The portable way to do this is to write
an application library that they can link to.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
