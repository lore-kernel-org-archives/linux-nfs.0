Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27723 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752198Ab3F0SFp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 14:05:45 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Marc Eshel <eshel@us.ibm.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "Adam C. Emerson" <aemerson@linuxbox.com>,
        "Matt W. Benjamin" <matt@linuxbox.com>
Subject: Re: NFSv4.1 session
Date: Thu, 27 Jun 2013 18:05:44 +0000
Message-ID: <1372356342.3365.1.camel@leira.trondhjem.org>
References: <OF8A324DEB.5C9C96EC-ON88257B97.0061DA51-88257B97.0062ED43@us.ibm.com>
In-Reply-To: <OF8A324DEB.5C9C96EC-ON88257B97.0061DA51-88257B97.0062ED43@us.ibm.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-06-27 at 11:00 -0700, Marc Eshel wrote:
> Hi Trond, 
> 
> I am not able to mount from Linux NFS client to the same Ganesha NFS
> server using multiple IP address. The client was providing the same
> client-id so the server was using the same session. I tried to return
> NFS4ERR_CLID_INUSE on the second mount if the target IP is different
> but the client still did not provide a different client-id like it
> should. I am not trying to use trunking I what to have different
> server instance for each IP address so I can move that IP between
> nodes in the cluster. Any ideas how to accomplish it. 
> 
> Thanks, Marc.

I don't understand. The client is performing exactly as per design: it
detects the fact that you are talking to the same server, and so it
reuses the same client and session. This is the only sane semantic for a
NFS client...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
