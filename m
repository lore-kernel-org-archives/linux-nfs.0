Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:33219 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753011AbdK0Rec (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Nov 2017 12:34:32 -0500
Received: by mail-qk0-f171.google.com with SMTP id 78so33427358qkz.0
        for <linux-nfs@vger.kernel.org>; Mon, 27 Nov 2017 09:34:32 -0800 (PST)
Message-ID: <1511804069.11547.10.camel@redhat.com>
Subject: Re: [PATCH v3 08/14] SUNRPC: add AF_VSOCK support to svc_xprt.c
From: Jeff Layton <jlayton@redhat.com>
To: Bruce Fields <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 27 Nov 2017 12:34:29 -0500
In-Reply-To: <20171127164641.GC25581@fieldses.org>
References: <20170630132352.32133-1-stefanha@redhat.com>
         <20170630132352.32133-9-stefanha@redhat.com>
         <1509459038.4553.26.camel@redhat.com>
         <20171107133111.GK6809@stefanha-x1.localdomain>
         <1510063286.4518.34.camel@redhat.com>
         <20171116152502.GG29106@stefanha-x1.localdomain>
         <A8EC5B49-872F-4D60-835C-5D1C2C04E362@oracle.com>
         <1511697511.9511.9.camel@redhat.com>
         <716BB5E5-C1B4-4003-8A82-3B9D3CC043FD@oracle.com>
         <20171127164641.GC25581@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-11-27 at 11:46 -0500, Bruce Fields wrote:
> On Sun, Nov 26, 2017 at 10:53:45AM -0500, Chuck Lever wrote:
> > 
> > > On Nov 26, 2017, at 6:58 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > > 
> > > On Thu, 2017-11-16 at 15:53 -0500, Chuck Lever wrote:
> > > > > On Nov 16, 2017, at 10:25 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> > > > > 
> > > > > On Tue, Nov 07, 2017 at 09:01:26AM -0500, Jeff Layton wrote:
> > > > > > On Tue, 2017-11-07 at 13:31 +0000, Stefan Hajnoczi wrote:
> > > > > > > On Tue, Oct 31, 2017 at 10:10:38AM -0400, Jeff Layton wrote:
> > > > > > > > On Fri, 2017-06-30 at 14:23 +0100, Stefan Hajnoczi wrote:
> > > > > > > > > @@ -595,6 +609,10 @@ int svc_port_is_privileged(struct sockaddr *sin)
> > > > > > > > > 	case AF_INET6:
> > > > > > > > > 		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
> > > > > > > > > 			< PROT_SOCK;
> > > > > > > > > +	case AF_VSOCK:
> > > > > > > > > +		return ((struct sockaddr_vm *)sin)->svm_port <=
> > > > > > > > > +			LAST_RESERVED_PORT;
> > > > > > > > > +
> > > > > > > > > 	default:
> > > > > > > > > 		return 0;
> > > > > > > > > 	}
> > > > > > > > 
> > > > > > > > Does vsock even have the concept of a privileged port? I would imagine
> > > > > > > > that root in a guest VM would carry no particular significance from an
> > > > > > > > export security standpoint
> > > > > > > > 
> > > > > > > > Since you're defining a new transport here, it might be nice write the
> > > > > > > > RFCs to avoid that distinction, if possible.
> > > > > > > > 
> > > > > > > > Note that RDMA just has svc_port_is_privileged always return 1.
> > > > > > > 
> > > > > > > AF_VSOCK has the same 0-1023 privileged port range as TCP.
> > > > > > > 
> > > > > > 
> > > > > > But why? And, given that you have 32-bits for a port with AF_VSOCK vs
> > > > > > the 16 bits on an AF_INET/AF_INET6, why is the range so pitifully small?
> > > > > > 
> > > > > > Reserved ports are a bit of a dinosaur holdover from when being root on
> > > > > > a machine on the Internet meant something. With v4.1 it's much less of
> > > > > > an issue, but in the "olden days", reserved port exhaustion could be a
> > > > > > real problem.
> > > > > > 
> > > > > > Mandating low ports can also be a problem in other way. Some well known
> > > > > > services use ports in the ephemeral range, and if your service starts
> > > > > > late and someone else has taken the port for an ephemeral one, you're
> > > > > > out of luck.
> > > > > > 
> > > > > > I think we have to ask ourselves:
> > > > > > 
> > > > > > Should the ability to open a low port inside of a VM carry any
> > > > > > significance at all to an RPC server? I'd suggest not, and I think it'd
> > > > > > be good to word the RFC to make that explicitly clear.
> > > > > 
> > > > > AF_VSOCK has had the reserved port range since it was first merged in
> > > > > 2013.  That's before my time but I do see some use for identifying
> > > > > connections coming from privileged processes.
> > > > > 
> > > > > Given that TCP has the same privileged port range, is there any reason
> > > > > why AF_VSOCK would be any worse off than TCP for having it?
> > > > 
> > > > I agree with Jeff that we need to think carefully about this.
> > > > 
> > > > I don't especially care for the privileged port check, but:
> > > > 
> > > > In this case, you are inventing an RPC transport that makes
> > > > it impossible to use strong security (ie, RPCSEC_GSS). We
> > > > should be careful about removing the check because only
> > > > AUTH_NULL and AUTH_UNIX security can be used in this kind
> > > > of deployment.
> > > > 
> > > 
> > > I know we've discussed this a bit, but does this transport _really_
> > > preclude us from using RPCSEC_GSS? I know we don't have IP addresses
> > > here, but hosts on either end of a vsocket will have hostnames.
> > 
> > Yes, even for AUTH_UNIX, something has to go in the "hostname"
> > field in the credential. Let's say the guest's uname.
> > 
> > 
> > > WRT kerberos, I don't see a reason why both hosts couldn't communicate
> > > with a KDC via other means, get tickets and then use those for
> > > authenticating over their vsock connection. vsock might make it harder
> > > to determine what SPN to use, but we could potentially work around that
> > > in other ways.
> > 
> > "No network configuration" implies to me that the KDC (or
> > a proxy for it) would have to reside on the host.

A proxy would be fine. The whole point of krb5 is that you can't rely on
 the network anyway...

> 
> Their requirement is that network configuration not be mandatory, not
> that it always be absent.
> 
> Then again maybe rpcsec_gss/vsock loses any advantage over
> rpcsec_gss/tcp if the former always requires a network anyway.
> 
> > > > Note also that the NFSv4 standards require that implementations
> > > > can support RPCSEC_GSS. NFSv4 on VSOCK cannot. Something will
> > > > have to be done about that.
> 
> Which might be: "Make an argument for why that requirement produces no
> useful result in this case". ?


I guess it just seems like we can allow RPCSEC_GSS over this channel,
even if it's not terribly useful today. I don't think we ought to word
in a way that specifically forbids it, unless it really does fall short
of some key requirement.

GSSAPI is more than just krb5 too...maybe LIPKEY will make a comeback
someday? :)

-- 
Jeff Layton <jlayton@redhat.com>
