From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
 part)
Date: Thu, 10 Sep 2009 12:43:39 -0400
Message-ID: <1252601019.8722.125.camel@heimdal.trondhjem.org>
References: <1249507356.5428.11.camel@heimdal.trondhjem.org>
	 <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com>
	 <1249515004.5428.34.camel@heimdal.trondhjem.org>
	 <20090909142945.755da393@tlielax.poochiereds.net>
	 <1252521599.8722.53.camel@heimdal.trondhjem.org>
	 <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com>
	 <1252525327.8722.81.camel@heimdal.trondhjem.org>
	 <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com>
	 <20090910150319.GA10704@fieldses.org>
	 <AD3CA71A-8A67-4D8E-8138-92A01D672133@oracle.com>
	 <20090910162327.GE11858@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@redhat.com>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:41330 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbZIJQnn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 12:43:43 -0400
In-Reply-To: <20090910162327.GE11858@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-09-10 at 12:23 -0400, J. Bruce Fields wrote:
> From a quick skim of http://www.ietf.org/rfc/rfc3490.txt, it appears to
> me that protocols (at the very least, any preexisting protocols) are all
> expected to use the ascii representation on the wire, and that the
> translation to unicode is meant by use for applications.
> 
> So in our case we'd continue to expect ascii domain names on the wire,
> and I believe that's also what we should store in any database.  But if
> someone were to write a gui administrative interface to that data, for
> example, they might choose to use idna for display.

Right. There should be no need to translate anything. Just store as is
and use as is...

Trond

