From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [NFS] [PATCH 010 of 14] knfsd: SUNRPC: add a "generic" function to see if the peer uses a secure port
Date: Wed, 13 Dec 2006 15:26:31 -0500
Message-ID: <76bd70e30612131226v2bb04437v8eb00705d85419bc@mail.gmail.com>
References: <20061213105528.21128.patches@notabene>
	 <1061212235927.21484@suse.de> <20061212174207.6180df0f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750744AbWLMU0f@vger.kernel.org>
To: "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20061212174207.6180df0f.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On 12/12/06, Andrew Morton <akpm@osdl.org> wrote:
> On Wed, 13 Dec 2006 10:59:27 +1100
> NeilBrown <neilb@suse.de> wrote:
>
> > From: Chuck Lever <chuck.lever@oracle.com>
> > The only reason svcsock.c looks at a sockaddr's port is to check whether
> > the remote peer is connecting from a privileged port.  Refactor this check
> > to hide processing that is specific to address format.
> >
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
> > Signed-off-by: Neil Brown <neilb@suse.de>
> >
> > ### Diffstat output
> >  ./net/sunrpc/svcsock.c |   20 +++++++++++++++++---
> >  1 file changed, 17 insertions(+), 3 deletions(-)
> >
> > diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
> > --- .prev/net/sunrpc/svcsock.c        2006-12-13 10:32:15.000000000 +1100
> > +++ ./net/sunrpc/svcsock.c    2006-12-13 10:32:17.000000000 +1100
> > @@ -926,6 +926,20 @@ svc_tcp_data_ready(struct sock *sk, int
> >               wake_up_interruptible(sk->sk_sleep);
> >  }
> >
> > +static inline int svc_port_is_privileged(struct sockaddr *sin)
> > +{
> > +     switch (sin->sa_family) {
> > +     case AF_INET:
> > +             return ntohs(((struct sockaddr_in *)sin)->sin_port) < 1024;
> > +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> > +     case AF_INET6:
> > +             return ntohs(((struct sockaddr_in6 *)sin)->sin6_port) < 1024;
> > +#endif
> > +     default:
> > +             return 0;
> > +     }
> > +}
>
> I'm a bit surprised to see this test implemented in sunrpc - it's the sort
> of thing which core networking should implement?

The check is open-coded in each socket type's bind callout, and
includes a capability check which I believe the NFS server doesn't
require.

> And should that "1024" be PROT_SOCK?

All I can say is.... "Doh!"  I'll send Neil a replacement with this fixed.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed
