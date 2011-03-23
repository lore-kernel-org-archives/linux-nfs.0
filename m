Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3969 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717Ab1CWV0r convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 17:26:47 -0400
Subject: Re: [PATCH 11/12] NFSv4.1: layoutcommit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20110323212157.GA14281@infradead.org>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
	 <1300886875-5016-12-git-send-email-iisaman@netapp.com>
	 <20110323210028.GA31040@infradead.org>
	 <1300914915.11677.88.camel@lade.trondhjem.org>
	 <20110323212157.GA14281@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 17:26:42 -0400
Message-ID: <1300915602.11677.91.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 17:21 -0400, Christoph Hellwig wrote:
> Okay, care to add a comment explaining this fact?  The name layoutcommit
> doesn't quite suggest that it doesn't commit anything but timestamps
> and size.
> 
> Can you recover the size from the data servers with the code above?  The
> size should also be on disk for an fdatasync.

Yes. The specification is that there can be no loss of data (even in the
case of a server crash) once the writes are committed to the data
server.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

