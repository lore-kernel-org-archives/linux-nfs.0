Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:54285 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756832Ab3LEQQN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Dec 2013 11:16:13 -0500
Date: Thu, 5 Dec 2013 11:15:17 -0500
From: Jim Rees <rees@umich.edu>
To: Christoph Hellwig <hch@infradead.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, Trond Myklebust <trondmy@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        An?bal Monsalve Salazar <anibal@debian.org>,
        "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
Message-ID: <20131205161517.GA6705@umich.edu>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain>
 <20131124051904.GA16651@master.debian.org>
 <20131124090924.GA29659@infradead.org>
 <20131124130753.GA15178@umich.edu>
 <20131204131317.GA7776@infradead.org>
 <108D7BCB-5869-45BB-A287-C6593257F193@oracle.com>
 <1021B36D-17B9-477F-A8AE-86D6A7750B80@gmail.com>
 <09856BCA-A255-4975-8144-D38775DC44A8@oracle.com>
 <20131205132341.GA3381@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131205132341.GA3381@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Arch lists the following:

librpcsecgss
URL            : http://www.citi.umich.edu/projects/nfsv4/linux/
Depends On     : glibc  krb5  libgssglue
Required By    : nfs-utils

libgssglue
URL            : http://www.citi.umich.edu/projects/nfsv4/linux/
Depends On     : glibc
Required By    : librpcsecgss  libtirpc  nfs-utils
