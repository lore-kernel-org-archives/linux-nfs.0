From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Tue, 20 May 2008 15:42:38 -0400
Message-ID: <1211312558.23156.29.camel@localhost>
References: <20080509152750.GA325@fieldses.org>
	 <20080509165204.GB1907@fieldses.org> <20080509171208.GC1907@fieldses.org>
	 <20080509235930.GM1907@fieldses.org>
	 <C4A41609-740F-450E-BE8F-7F51A8A9327B@oracle.com>
	 <1210440728.12927.5.camel@localhost>
	 <5FE6354F-8E28-4697-A27D-8532FD547683@oracle.com>
	 <1d07ca700805101807s7c034b08sc531993aa81010b2@mail.gmail.com>
	 <20080516195326.GD14228@fieldses.org>
	 <CF603745-0163-469F-AC12-B4C5747038FC@oracle.com>
	 <20080520024734.GA23457@fieldses.org>
	 <F7A2B33E-BD03-473E-ABA3-F51DE366F2ED@oracle.com>
	 <1211311935.23156.15.camel@localhost>
	 <6C0F215B-C450-4BF7-8099-F19CF1397403@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"david m. richter" <richterd@gmail.com>, linux-nfs@vger.kernel.org,
	Manoj Naik <manoj@almaden.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:58383 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757567AbYETTmr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 15:42:47 -0400
In-Reply-To: <6C0F215B-C450-4BF7-8099-F19CF1397403@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-20 at 15:38 -0400, Chuck Lever wrote:

> I assume this new mechanism is intended to handle IPv6 addresses and  
> DNS resolution correctly because it will invoke mount.nfs.

I hadn't explicitly considered the problem of IPv6 addresses but yes, we
should get all that for free.

  Trond

