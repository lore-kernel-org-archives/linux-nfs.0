Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58169 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaEOPdI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2014 11:33:08 -0400
Date: Thu, 15 May 2014 08:33:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: JA Magall??n <jamagallon@ono.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: NFSACL broken from 3.13 to 3.14
Message-ID: <20140515153307.GA9016@infradead.org>
References: <5374CE6B.6030905@ono.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5374CE6B.6030905@ono.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 15, 2014 at 04:25:47PM +0200, JA Magall??n wrote:
> I mount homes from a Solaris 10 server, via NFSv3. Solaris nfs has a special
> sideband server on a port for NFS to check ACLs. With previous version of
> kernel (3.13.10 was the latest I check), I need no special option to mount
> Solaris shares. With 3.14, it began to give errors, directories created
> with mkdir returned error, files got created but truncated to 0 size...
> (now I have 3.14.3).
> 
> I solved it adding the 'noacl' option to Solaris mount entries in autofs,
> so the linux clients don't use the sideband protocol.
> 
> As I have read, NFSACL usage is negotitated between client and server.
> Something has changed and the negotiation fails, perhaps ?

We have some pretty bug ACL changes in 3.14.  I've tested it against a
Linux server, but don't have a Solaris server available.  Do you have
something like strace or wireshark traces to show differences between
the versions?
