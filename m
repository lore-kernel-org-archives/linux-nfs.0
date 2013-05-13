Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:57815 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753078Ab3EMPcS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2013 11:32:18 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.11 patches
Date: Mon, 13 May 2013 15:28:09 +0000
Message-ID: <1368458889.3563.7.camel@leira.trondhjem.org>
References: <20130513152312.GB1931@fieldses.org>
In-Reply-To: <20130513152312.GB1931@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-05-13 at 11:23 -0400, J. Bruce Fields wrote:
> I've added a labeled-nfs-common branch at
> 
> 	git://linux-nfs.org/~bfields/linux.git labeled-nfs-common
> 
> with 3.10-rc1 + the one labeled NFS patch shared by client and server
> (with just some protocol constants).
> 
> So we can all work on top of that if we want.

OK. I've pushed out a 'labeled-nfs' branch for the client side that is
based upon the above branch.

Has James added the security patches to a public branch that we can pull
yet?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
