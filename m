From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] sunrpc: split the vs_hidden flag into TCP and UDP
 variants
Date: Fri, 25 Jun 2010 10:37:42 -0400
Message-ID: <1277476662.6141.0.camel@heimdal.trondhjem.org>
References: <1277429621-9579-1-git-send-email-jlayton@redhat.com>
	 <BF3BB6D12298F54B89C8DCC1E4073D800183CAB2@CORPUSMX50A.corp.emc.com>
	 <1277471650.2881.6.camel@heimdal.trondhjem.org>
	 <20100625103503.011ae577@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Staubach_Peter@emc.com, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:49674 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755951Ab0FYOhu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jun 2010 10:37:50 -0400
In-Reply-To: <20100625103503.011ae577-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-06-25 at 10:35 -0400, Jeff Layton wrote:
> On Fri, 25 Jun 2010 09:14:10 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > On Fri, 2010-06-25 at 08:58 -0400, Staubach_Peter@emc.com wrote:
> > > Does this mean that the Linux NFS server will no longer respond to NFSv4
> > > requests coming in over UDP?  If it will continue to do so, wouldn't it
> > > be more important to solve that correctly?
> > 
> > Agreed. Either we keep UDP support on the server and advertise it too,
> > or we should throw it out altogether...
> > 
> 
> Ok, I'll start working on it. A question though...
> 
> When we get a NFSv4 request over UDP, what's the correct response?
> A PROG_MISMATCH RPC error?
> 

Yes. A PROG_MISMATCH would be appropriate for that case.

Cheers
  Trond

