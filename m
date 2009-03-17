From: Greg Banks <gnb@sgi.com>
Subject: Re: Horrible NFS Client Performance During Heavy Server IO
Date: Tue, 17 Mar 2009 15:43:59 +1100
Message-ID: <49BF2A8F.7030607@sgi.com>
References: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com> <1236978608.7265.41.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Rees <drees76@gmail.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:54344 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751486AbZCQEjV (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2009 00:39:21 -0400
In-Reply-To: <1236978608.7265.41.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Fri, 2009-03-13 at 13:36 -0700, David Rees wrote:
>   
>>     
>
> You don't need conv=fdatasync when writing to NFS. The close-to-open
> cache consistency automatically guarantees fdatasync on close().
>   
Yes...but at least some versions of dd will print a performance number
at the end, where the time delta used in the calculation includes the
fdatasync() time but not the close() time.  So conv=fdatasync is a
useful trick to get accurate performance numbers from dd.  Personally I
don't use that metric from dd because it's a simple overall average and
I like to watch the time behaviour of the transfer rate.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

