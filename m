From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: split the vs_hidden flag into TCP and UDP
 variants
Date: Fri, 25 Jun 2010 10:35:03 -0400
Message-ID: <20100625103503.011ae577@tlielax.poochiereds.net>
References: <1277429621-9579-1-git-send-email-jlayton@redhat.com>
	<BF3BB6D12298F54B89C8DCC1E4073D800183CAB2@CORPUSMX50A.corp.emc.com>
	<1277471650.2881.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Staubach_Peter@emc.com, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8319 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812Ab0FYOfP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jun 2010 10:35:15 -0400
In-Reply-To: <1277471650.2881.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 25 Jun 2010 09:14:10 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Fri, 2010-06-25 at 08:58 -0400, Staubach_Peter@emc.com wrote:
> > Does this mean that the Linux NFS server will no longer respond to NFSv4
> > requests coming in over UDP?  If it will continue to do so, wouldn't it
> > be more important to solve that correctly?
> 
> Agreed. Either we keep UDP support on the server and advertise it too,
> or we should throw it out altogether...
> 

Ok, I'll start working on it. A question though...

When we get a NFSv4 request over UDP, what's the correct response?
A PROG_MISMATCH RPC error?

-- 
Jeff Layton <jlayton@redhat.com>
