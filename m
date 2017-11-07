Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:43233 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdKGOBa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Nov 2017 09:01:30 -0500
Received: by mail-qk0-f173.google.com with SMTP id 78so8375266qkz.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Nov 2017 06:01:30 -0800 (PST)
Message-ID: <1510063286.4518.34.camel@redhat.com>
Subject: Re: [PATCH v3 08/14] SUNRPC: add AF_VSOCK support to svc_xprt.c
From: Jeff Layton <jlayton@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: linux-nfs@vger.kernel.org, Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Date: Tue, 07 Nov 2017 09:01:26 -0500
In-Reply-To: <20171107133111.GK6809@stefanha-x1.localdomain>
References: <20170630132352.32133-1-stefanha@redhat.com>
         <20170630132352.32133-9-stefanha@redhat.com>
         <1509459038.4553.26.camel@redhat.com>
         <20171107133111.GK6809@stefanha-x1.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-11-07 at 13:31 +0000, Stefan Hajnoczi wrote:
> On Tue, Oct 31, 2017 at 10:10:38AM -0400, Jeff Layton wrote:
> > On Fri, 2017-06-30 at 14:23 +0100, Stefan Hajnoczi wrote:
> > > @@ -595,6 +609,10 @@ int svc_port_is_privileged(struct sockaddr *sin)
> > >  	case AF_INET6:
> > >  		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
> > >  			< PROT_SOCK;
> > > +	case AF_VSOCK:
> > > +		return ((struct sockaddr_vm *)sin)->svm_port <=
> > > +			LAST_RESERVED_PORT;
> > > +
> > >  	default:
> > >  		return 0;
> > >  	}
> > 
> > Does vsock even have the concept of a privileged port? I would imagine
> > that root in a guest VM would carry no particular significance from an
> > export security standpoint
> > 
> > Since you're defining a new transport here, it might be nice write the
> > RFCs to avoid that distinction, if possible.
> > 
> > Note that RDMA just has svc_port_is_privileged always return 1.
> 
> AF_VSOCK has the same 0-1023 privileged port range as TCP.
> 

But why? And, given that you have 32-bits for a port with AF_VSOCK vs
the 16 bits on an AF_INET/AF_INET6, why is the range so pitifully small?

Reserved ports are a bit of a dinosaur holdover from when being root on
a machine on the Internet meant something. With v4.1 it's much less of
an issue, but in the "olden days", reserved port exhaustion could be a
real problem.

Mandating low ports can also be a problem in other way. Some well known
services use ports in the ephemeral range, and if your service starts
late and someone else has taken the port for an ephemeral one, you're
out of luck.

I think we have to ask ourselves:

Should the ability to open a low port inside of a VM carry any
significance at all to an RPC server? I'd suggest not, and I think it'd
be good to word the RFC to make that explicitly clear.

-- 
Jeff Layton <jlayton@redhat.com>
