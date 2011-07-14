Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41497 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754585Ab1GNNQt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2011 09:16:49 -0400
Date: Thu, 14 Jul 2011 09:16:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: krb5 failures with recent nfs-utils
Message-ID: <20110714131647.GC13000@fieldses.org>
References: <20110713225939.GA13000@fieldses.org>
 <4E1E9725.5020707@desy.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E1E9725.5020707@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 14, 2011 at 09:13:41AM +0200, Tigran Mkrtchyan wrote:
> On 07/14/2011 12:59 AM, J. Bruce Fields wrote:
> >On Fedora 15 I'm seeing odd krb5 behavior: the context initialization
> >appears to work fine, but then gssd sends a malformed RPCSEC_GSS_DESTROY
> >packet just before closing the connection.  The client's first operation
> >to the server using the context is rejected because the server's mic
> >verification fails.
> >
> >Has anyone else seen this?
> 
> I have reported the same issue couple of weeks ago
> 
> http://www.spinics.net/lists/linux-nfs/msg22142.html

I thought it looked familiar....

> I use suse 11.4 x86_64 and can reproduce it with native kernel
> 2.6.37.xxx and 3.0.0-rc5.
> 
> To me it looks like that in rpc packet missing verifier.

Yes.

> Nevertheless
> the message length is up to verifier. What I failed to find out it
> the message length did not take verifier in the account or verifier
> is missing in the first place. I was looking the the kernel code,
> but may be problem is in gssd. I don't know which part of gss
> handling in user space and which part is in the kernel.

It's gssd that handles the init_sec_context, and (what I didn't notice
before) you can see that the destroy rpc goes over the same tcp
connection as the init_sec_context exchange.

--b.
