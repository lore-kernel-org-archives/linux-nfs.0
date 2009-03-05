From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/6] Further nfs-utils clean ups
Date: Thu, 05 Mar 2009 06:26:52 -0500
Message-ID: <49AFB6FC.5080702@RedHat.com>
References: <20090304234711.28749.7018.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35569 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868AbZCEL3c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2009 06:29:32 -0500
In-Reply-To: <20090304234711.28749.7018.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> Here are six more patches that clean up various issues to prepare for
> the widespread use of TI-RPC in nfs-utils.
> 
> We discovered a type width mismatch issue between our legacy RPC
> headers and the TI-RPC run-time that will be addressed in a subsequent
> patch series by using TI-RPC to build all of nfs-utils.  This issue
> should be addressed before the next release of nfs-utils is published.
> 
> The idea will be to build nfs-utils with either glibc's legacy RPC
> implementation and the legacy RPC headers (as it is today in 1.1.3),
> or with libtirpc and TI-RPC's headers, based on the setting of
> --enable-tirpc (which defaults to --disable-tirpc).
> 
> This further insulates ongoing IPv6 work from folks who need to use
> today's up-to-date version of nfs-utils, while easily allowing us to
> test a version built with complete TI-RPC integration.
> 
Committed...

steved.
