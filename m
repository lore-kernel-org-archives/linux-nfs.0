Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:52527 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbaBCORd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 09:17:33 -0500
Received: by mail-ie0-f175.google.com with SMTP id ar20so6264126iec.20
        for <linux-nfs@vger.kernel.org>; Mon, 03 Feb 2014 06:17:32 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: NFS client broken in Linus' tip
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140203080325.GB806@infradead.org>
Date: Mon, 3 Feb 2014 09:17:30 -0500
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Viro Alexander <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org
Message-Id: <85AAFCF5-60EE-42E5-B103-37A4613C5947@primarydata.com>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk> <20140130141405.GA23985@infradead.org> <20140130142752.GX15937@n2100.arm.linux.org.uk> <20140130143208.GB9573@infradead.org> <20140130153812.GA15937@n2100.arm.linux.org.uk> <1391201970.6978.1.camel@leira.trondhjem.org> <20140203080325.GB806@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 3, 2014, at 3:03, Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, Jan 31, 2014 at 03:59:30PM -0500, Trond Myklebust wrote:
>> posix_acl_xattr_get requires get_acl() to return EOPNOTSUPP if the
>> filesystem cannot support acls. This is needed for NFS, which can't
>> know whether or not the server supports acls until it tries to get/set
>> one.
>> This patch converts posix_acl_chmod and posix_acl_create to deal with
>> EOPNOTSUPP return values from get_acl().
> 
> Shouldn't NFS just return a NULL ACL here?

As I said above, that causes posix_acl_xattr_get() to return the wrong answer (ENODATA instead of EOPNOTSUPP).

--
Trond Myklebust
Linux NFS client maintainer

