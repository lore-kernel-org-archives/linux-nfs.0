Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57908 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773Ab1HDFyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2011 01:54:33 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <20026.13331.411712.805796@regina.usersys.redhat.com>
Date: Thu, 4 Aug 2011 15:54:27 +1000
From: Max Matveev <makc@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: NFS/TCP timeout sequence
In-Reply-To: <1310050752.3863.51.camel@lade.trondhjem.org>
References: <19989.27202.793003.725608@regina.usersys.redhat.com>
	<1310046439.3863.30.camel@lade.trondhjem.org>
	<5F749FAD-94B0-4D9D-84F6-F7D9662A1CF6@oracle.com>
	<1310048213.3863.37.camel@lade.trondhjem.org>
	<7464E63E-E02E-4E4F-95A4-D4CF235DAFB3@oracle.com>
	<1310050752.3863.51.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Resuming a conversation from last month - it fizzed out and died
without any resoltion...

On Thu, 07 Jul 2011 10:59:12 -0400, Trond Myklebust wrote:

 trond> Looking at the code:

 trond> v2.6.0: exponential back off
 trond> v2.6.4: exponential back off
 trond> v2.6.9: exponential back off
 trond> v2.6.16: linear back off
 trond> v2.6.18: linear back off
 trond> v2.6.24: linear back off
 trond> v2.6.32: linear back off
 trond> ....

 trond> So I've no idea what you were testing.

I'm going to assume that we're keeping linear backoff and
send a patch which correct calculation of maxint for this case.

 >> So it seems to me the kernel has diverged (perhaps long ago) from
 >> the documentation, not the other way around.

 trond> Nope. The documentation has simply always been inaccurate afaics from
 trond> the above inspection.

And another one to update the documentation..

max

