Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760288Ab3ECTRJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 May 2013 15:17:09 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1367596129.3556.5.camel@leira.trondhjem.org>
References: <1367596129.3556.5.camel@leira.trondhjem.org> <14F179B8-573E-4F6A-942B-565529BFB343@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: dhowells@redhat.com, "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: trond/testing tainted
Date: Fri, 03 May 2013 20:17:06 +0100
Message-ID: <7825.1367608626@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> Was this intentional? It seems strange that code that can be compiled
> into the kernel without any problems should taint it when compiled as a
> module.

No...  It didn't occur to me to add the module info.  If you have module
signing enabled, then this has to be built in.

I'll patch it.

David
