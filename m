From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Sat, 10 May 2008 10:32:08 -0700
Message-ID: <1210440728.12927.5.camel@localhost>
References: <20080509011918.GK12690@fieldses.org>
	 <1210309839.8657.0.camel@localhost> <20080509152750.GA325@fieldses.org>
	 <20080509165204.GB1907@fieldses.org> <20080509171208.GC1907@fieldses.org>
	 <20080509235930.GM1907@fieldses.org>
	 <C4A41609-740F-450E-BE8F-7F51A8A9327B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org,
	Manoj Naik <manoj@almaden.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46091 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752816AbYEJRcV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 May 2008 13:32:21 -0400
In-Reply-To: <C4A41609-740F-450E-BE8F-7F51A8A9327B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-05-09 at 19:29 -0700, Chuck Lever wrote:
> Should you use in4_pton() instead?

Can we rather convert this to use nfs_parse_server_address? We don't
need 10 different ways to parse text addresses...

Trond

