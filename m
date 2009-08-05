From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
 part)
Date: Wed, 05 Aug 2009 17:22:36 -0400
Message-ID: <1249507356.5428.11.camel@heimdal.trondhjem.org>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
	 <20090805144540.12866.22084.stgit@matisse.1015granger.net>
	 <20090805174811.GB9944@fieldses.org>
	 <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com>
	 <20090805181545.GF9944@fieldses.org>
	 <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45097 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090AbZHEVWo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Aug 2009 17:22:44 -0400
In-Reply-To: <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-08-05 at 14:26 -0400, Chuck Lever wrote:

> sqlite3 doesn't do anything special under the covers.  It uses only  
> POSIX file access and locking calls, as far as I know.  So I think  
> hosting /var on most well-behaved clustering file systems won't have  
> any problem with this arrangement.

So we're basically introducing a dependency on a completely new library
that will have to be added to boot partitions/nfsroot/etc, and we have
no real reason for doing it other than because we want to move from
using sync() to fsync()?

Sounds like a NACK to me...

Trond

