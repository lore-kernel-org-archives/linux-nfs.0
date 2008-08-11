From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfsd: permit unauthenticated stat of export root
Date: Mon, 11 Aug 2008 17:38:31 -0400
Message-ID: <1218490711.12593.16.camel@localhost>
References: <20080807181148.GK18904@fieldses.org>
	 <489B3DAC.5060004@redhat.com> <20080807191656.GL18904@fieldses.org>
	 <489B4F81.8000204@redhat.com> <20080807204154.GR18904@fieldses.org>
	 <48A0AEDC.3080308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:43032 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654AbYHKVik (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2008 17:38:40 -0400
In-Reply-To: <48A0AEDC.3080308@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-08-11 at 17:27 -0400, Peter Staubach wrote:
> A better description of the set of operations which should be
> allowed and which ones are not should include a discussion on
> the contents of the response to the FSINFO request.  If the
> server returns attributes in the FSINFO response, then it does
> not need to allow unauthenticated GETATTR requests.  If it does
> not return attributes in the FSINFO response, then it must allow
> unauthenticated GETATTR requests because this is required in
> order to allow clients to successfully mount file systems using
> strong authentication.

Well... That's true for NFSv3, but if your server also supports
NFSv2-with-RPCSEC_GSS, then it also has to support the NFSv2 FSSTAT
+GETATTR under AUTH_SYS.

In any case, this is an issue of efficiency rather than security.
Whether you allow FSINFO w/ post-op attributes but no GETATTR, or you
allow FSINFO w/o post-op attributes and allow GETATTR on the mountpoint
is entirely equivalent from the security viewpoint: the amount of
information available using weak security is the same.

Cheers,
   Trond

