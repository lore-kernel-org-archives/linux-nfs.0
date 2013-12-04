Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:36090 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932899Ab3LDROx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 12:14:53 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131204131317.GA7776@infradead.org>
Date: Wed, 4 Dec 2013 12:14:23 -0500
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Message-Id: <108D7BCB-5869-45BB-A287-C6593257F193@oracle.com>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain> <20131124051904.GA16651@master.debian.org> <20131124090924.GA29659@infradead.org> <20131124130753.GA15178@umich.edu> <20131204131317.GA7776@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 4, 2013, at 8:13 AM, Christoph Hellwig <hch@infradead.org> wrote:

> Btw, looks like librpcsecgss is indeed pretty much unmaintained.  The
> last upstream release is a tarball drop from CITI in 2009 and there
> doesn't appear to be a source repository of any kind.
> 
> I think the best idea would be to merge it into the libtirpc repo,
> as both the heritage and usage of the codebases is the same.

Comparing what's packaged in nfs-utils-lib and what's in libtirpc: it appears libtirpc already has librpcsecgss.

I assume librpcsecgss is still required on systems that use glibc's RPC implementation.  But for systems that have libtirpc, maybe librpcsecgss is unneeded?

Note: the GSS API provided here is not documented, AFAICT, and does not match the de facto standard provided by a modern Solaris libtirpc.  I'd like to add the standard API to libtirpc and deprecate (but not remove) the current GSS API.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



