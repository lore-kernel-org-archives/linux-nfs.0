From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs + Reiser4
Date: Fri, 09 Apr 2010 08:30:51 -0400
Message-ID: <1270816251.3055.8.camel@localhost.localdomain>
References: <op.vaq49joctxpshh@localhost.localdomain>
	 <20100407173438.GA25614@fieldses.org> <4BBCD271.5040100@oracle.com>
	 <20100407185157.GF26072@fieldses.org> <4BBCD618.50301@oracle.com>
	 <20100407192025.GH26072@fieldses.org>
	 <1270674567.3177.2.camel@localhost.localdomain>
	 <4BBCFA28.2030101@catking.net>
	 <1270680542.6995.21.camel@localhost.localdomain>
	 <4BBE448A.3050408@catking.net>
	 <1270762431.7276.28.camel@localhost.localdomain>
	 <4BBF18E5.5080306@catking.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50166 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181Ab0DIMa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Apr 2010 08:30:58 -0400
In-Reply-To: <4BBF18E5.5080306-B3jsHfKwJfLR7s880joybQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-04-09 at 14:09 +0200, gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org wrote: 
> I was refering to man nfs which states that nfs will always try nfs3 and 
> if it fails falls back to ver 2. Maybe man nfs is not the definitive 
> reference for what is in the kernel if this has changed recently.

The above is true for the ordinary 'mount' program, but is not true of
nfsroot.

The fallback policy for mount is now managed entirely in userspace, and
in recent versions of nfs-utils, you can configure whether you want
nfsv4, nfsv3 or nfsv2 to be the default.

Cheers
  Trond

