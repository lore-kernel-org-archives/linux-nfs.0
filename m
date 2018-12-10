Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D226BC5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 19:00:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9AC96204FD
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 19:00:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AC96204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727145AbeLJTAt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 14:00:49 -0500
Received: from fieldses.org ([173.255.197.46]:59504 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726024AbeLJTAt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Dec 2018 14:00:49 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 821671C27; Mon, 10 Dec 2018 14:00:48 -0500 (EST)
Date:   Mon, 10 Dec 2018 14:00:48 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@redhat.com>
Subject: Re: listing knfsd-held locks and opens
Message-ID: <20181210190048.GB2925@fieldses.org>
References: <20181210174720.GA2925@fieldses.org>
 <08F6A3D9-6FF3-452A-BCD6-390ECA142136@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <08F6A3D9-6FF3-452A-BCD6-390ECA142136@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 10, 2018 at 12:49:02PM -0500, Chuck Lever wrote:
> > On Dec 10, 2018, at 12:47 PM, bfields@fieldses.org wrote:
> > In a little more detail, as starting point, I was considering naming
> > each client directory with a small integer, and including files like:
> > 
> > 	info: a text file with
> > 		NFS protocol version
> > 		ascii representation of client address
> > 		krb5 principal if available
> > 
> > 	clientid: NFSv4 client ID; file absent for NFSv2/3 clients.
> > 
> > 	locks: list of locks, following something like the /proc/locks
> > 		format.
> > 
> > 	opens: list of file opens, with access bits, inode numbers,
> > 		device number.
> > 
> > Does that sound reasonable?  Any other ideas?
> 
> How do you plan to make this kernel API namespace-aware?

I may have some details wrong, but:

We associate most of nfsd's state with the network namespace.  The
"nfsd" pseudofilesystem is where I'm thinking I might put this, and it
inherits the network namespace from the process that calls mount and
stores it in the superblock.  So each mount done in a different net
namespace should get its own superblock, its own inodes, etc.  

(I think that's how proc works, too?)

So when you set up containerized nfsd, you mount a new nfsd filesystem
in each container.  And the list of clients visible there should only be
the ones visible to that namespace.

I guess that means that if you share an export across multiple
containers, then if you want to find all the clients locking a given
file, you have to iterate over all the container's "nfsd" mounts.

I suspect that's what we have to do, though.  I mean, the client
addresses, for example, may not even make sense unless you know which
network namespace they come from.

(On the other hand... how does /proc/locks actually work?  Looks to me
like it always lists every lock on the system.  Can it really translate
any process on the system into a pid that makes sense in any container?
I'm not following that, from a brief look at the code.)

--b.
