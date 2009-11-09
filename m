From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Question: NFS behaviour in case of concurrent local and remote
 access
Date: Mon, 09 Nov 2009 08:25:36 -0500
Message-ID: <1257773136.3754.17.camel@heimdal.trondhjem.org>
References: <1257770569.7276.31.camel@home.yosifov.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Ivan Yosifov <iyosifov@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:38919 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750931AbZKINZe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2009 08:25:34 -0500
In-Reply-To: <1257770569.7276.31.camel-+yaoqMNIL58NKrj9nap9fg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-11-09 at 14:42 +0200, Ivan Yosifov wrote:
> Hi everyone,
> 
> I'm new to NFS and am trying to understand how to use it safely and
> correctly.
> 
> The situation I'm considering is following. There's a server with an
> ( ext4 if it matters ) local volume that's exported through NFSv4. There
> are expected to be both remote ( ie. over the NFS ) read/write clients
> and local ones that write to the volume directly ( ie. not thorough the
> NFS ).
> 
> Assuming well-behaved clients, ie. no interleaved open()...close() on
> the same file, how will NFS handle this ? Will close-to-open consistency
> continue to work, will it interfere with delegations ?
> 
> Pointers or thoughts greatly appreciated.

The NFS expectation is that if one application is writing to a file
while another is holding it open, then the two applications will use
locking in order to synchronise their access.

As long as all applications adhere to this rule, then you are supposed
to be guaranteed cache consistency. It shouldn't matter if the
applications are running on the server or on another client.

Cheers
   Trond

