From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: Add support to svcgssd to limit the negotiated
 enctypes
Date: Wed, 06 Apr 2011 11:32:01 -0400
Message-ID: <4D9C8771.7010608@RedHat.com>
References: <20110317012919.7982.12281.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53579 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932080Ab1DFPcD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 11:32:03 -0400
In-Reply-To: <20110317012919.7982.12281.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/16/2011 09:29 PM, Kevin Coffman wrote:
> Recent versions of Kerberos libraries negotiate and use
> an "acceptor subkey".  This negotiation does not consider
> that a service may have limited the encryption keys in its
> keytab.  A patch (http://src.mit.edu/fisheye/changelog/krb5/?cs=24603)
> has been added to the MIT Kerberos code to allow an application
> to indicate that it wants to limit the encryption types negotiated.
> (This functionality has been available on the client/initiator
> side for a while.  The new patch adds this support to the
> server/acceptor side.)
> 
> This patch adds support to read a recently added nfsd
> proc file to determine the encryption types supported by
> the kernel and calls the function to limit encryption
> types negotiated for the acceptor subkey.
> 
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Committed..

steved.
