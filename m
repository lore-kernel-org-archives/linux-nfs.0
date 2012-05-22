Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13732 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752657Ab2EVAiX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 May 2012 20:38:23 -0400
Subject: Re: [PATCH 2/4] SUNRPC: Document a bit RPCGSS handling in the NFS
 Server
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <20120521215544.GD28221@fieldses.org>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
	 <1337087550-9821-3-git-send-email-simo@redhat.com>
	 <20120521215544.GD28221@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 21 May 2012 20:37:32 -0400
Message-ID: <1337647052.16840.173.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-05-21 at 17:55 -0400, J. Bruce Fields wrote:
> On Tue, May 15, 2012 at 09:12:28AM -0400, Simo Sorce wrote:
> > Includes changes intorduced by GSS-Proxy.
> > 
> > Signed-off-by: Simo Sorce <simo@redhat.com>
> > ---
> >  Documentation/filesystems/nfs/00-INDEX         |    2 +
> >  Documentation/filesystems/nfs/knfsd-rpcgss.txt |   65 ++++++++++++++++++++++++
> >  2 files changed, 67 insertions(+), 0 deletions(-)
> >  create mode 100644 Documentation/filesystems/nfs/knfsd-rpcgss.txt
> > 
> > diff --git a/Documentation/filesystems/nfs/00-INDEX b/Documentation/filesystems/nfs/00-INDEX
> > index 1716874a651e1c574e7ca9719dfb4e3521b0a5e9..66eb6c8c5334518ddbc10115c7b34b4dfb1b3c0e 100644
> > --- a/Documentation/filesystems/nfs/00-INDEX
> > +++ b/Documentation/filesystems/nfs/00-INDEX
> > @@ -20,3 +20,5 @@ rpc-cache.txt
> >  	- introduction to the caching mechanisms in the sunrpc layer.
> >  idmapper.txt
> >  	- information for configuring request-keys to be used by idmapper
> > +knfsd-rpcgss.txt
> > +	- Information on GSS authentication support in the NFS Server
> > diff --git a/Documentation/filesystems/nfs/knfsd-rpcgss.txt b/Documentation/filesystems/nfs/knfsd-rpcgss.txt
> > new file mode 100644
> > index 0000000000000000000000000000000000000000..914aa536273b986539d7859092e2c0f139ce5535
> > --- /dev/null
> > +++ b/Documentation/filesystems/nfs/knfsd-rpcgss.txt
> > @@ -0,0 +1,65 @@
> > +
> > +Kernel NFS Server RPCGSS Support
> > +================================
> > +
> > +This document gives references to the standards and protocols used to
> > +implement RPCGSS authentication in the NFS Server.
> > +
> > +RPCGSS is specified in a few IETF documents:
> > + - RFC2203 v1: http://tools.ietf.org/rfc/rfc2203.txt
> > + - RFC5403 v2: http://tools.ietf.org/rfc/rfc5403.txt
> > +and there is a 3rd version  being proposed:
> > + - http://tools.ietf.org/id/draft-williams-rpcsecgssv3.txt
> > +   (At draft n. 02 at the time of writing)
> > +
> > +Background
> > +----------
> > +
> > +The RPCGSS Authentication method describes a way to perform GSSAPI
> > +Authentication for NFS.
> > +Although GSSAPI is itself completely mechanism agnostic, in many cases only
> > +the KRB5 mechanism is supported by NFS implementations.
> > +
> > +The Linux kernel, at the moment, supports only the KRB5 mechanism, and depends
> > +on GSSAPI extensions that are KRB5 specific.
> > +
> > +GSSAPI is a complex library, and implementing it completely in kernel is
> > +unwarranted. However GSSAPI operations are fundementally separable in 2 parts:
> > +- context establishment
> > +- integrity/privacy protection (read: signing and encrypting)
> > +
> > +The first part is the complex one, while the actual integrity and privacy
> > +protecion is simple enough.
> > +Because of the complexity of context establishment, the NFS Server defers the
> > +operation to the userspace througuh the use of upcalls.
> > +
> > +NFS Server Legacy Upcall mechanism
> > +----------------------------------
> > +
> > +The classic upcall mechanism uses a custom text based upcall mechanism to talk
> > +to a custom daemon called rpc.svcgssd that is provide by the nfs-utils package.
> > +
> > +This upcall mechanism has 2 limitations:
> > +A) Can handle tokens that are no bigger than 2KiB
> > +
> > +In some Kerberos deployment GSSAPI tokens can be quite big, up and beyond 64KiB
> > +in size due to various authorization extensions attacked to the Kerberos
> > +tickets, that needs to be sent through the GSS layer in order to perform
> > +context establishment.
> > +
> > +B) Does not properly handle creds where the user is member of more than a few
> > +housand groups (the current hard limit in the kernel is 65K groups) due to
> > +limitation on the size of the buffer that can be send back to the kernel (4KiB).
> > +
> > +NFS Server New RPC Upcall mechanism
> > +-----------------------------------
> > +
> > +A new upcall mechanism that uses RPC over a Unix socket is added. This
> > +mechanism uses a protocol called gss-proxy, and user space program that
> > +implements it called Gssproxy. The gss_proxy RPC protocol is currently document
> > +here: https://fedorahosted.org/gss-proxy/wiki/ProtocolDocumentation
> 
> That's helpful, thanks.
> 
> I thought there were a couple other ways in which the gss-proxy<->kernel
> protocol would differ slightly from the full protocol.  (Some fields
> which we "know" will always be left empty?)  Do I remember right, and if
> so are those documented someplace too?

Nope, nothing special, we simply ignore fields we are not interested to
in the reply. The special handling for that is all in kernel and does
not affect the actual protocol.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

