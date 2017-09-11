Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41118 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751514AbdIKQWS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Sep 2017 12:22:18 -0400
Date: Mon, 11 Sep 2017 12:22:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [RFC v3 16/42] NFS NFSD defining nl4_servers structure needed by
 both
Message-ID: <20170911162217.GB31845@fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-17-kolga@netapp.com>
 <20170906203520.GB24694@fieldses.org>
 <CAN-5tyFrVnC0dRVMxbUwaFoiGHbMDdF=Q-V69tihYPWy6gmYJQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyFrVnC0dRVMxbUwaFoiGHbMDdF=Q-V69tihYPWy6gmYJQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 08, 2017 at 04:51:59PM -0400, Olga Kornievskaia wrote:
> On Wed, Sep 6, 2017 at 4:35 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Tue, Jul 11, 2017 at 12:43:50PM -0400, Olga Kornievskaia wrote:
> >> These structures are needed by COPY_NOTIFY on the client and needed
> >> by the nfsd as well
> >>
> >> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> >> ---
> >>  include/linux/nfs4.h | 33 +++++++++++++++++++++++++++++++++
> >>  1 file changed, 33 insertions(+)
> >>
> >> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> >> index 7262908..4179c78 100644
> >> --- a/include/linux/nfs4.h
> >> +++ b/include/linux/nfs4.h
> >> @@ -15,6 +15,7 @@
> >>  #include <linux/list.h>
> >>  #include <linux/uidgid.h>
> >>  #include <uapi/linux/nfs4.h>
> >> +#include <linux/sunrpc/msg_prot.h>
> >>
> >>  enum nfs4_acl_whotype {
> >>       NFS4_ACL_WHO_NAMED = 0,
> >> @@ -659,4 +660,36 @@ struct nfs4_op_map {
> >>       } u;
> >>  };
> >>
> >> +struct nfs42_netaddr {
> >> +     unsigned int    na_netid_len;
> >> +     char            na_netid[RPCBIND_MAXNETIDLEN + 1];
> >> +     unsigned int    na_uaddr_len;
> >> +     char            na_uaddr[RPCBIND_MAXUADDRLEN + 1];
> >> +};
> >> +
> >> +enum netloc_type4 {
> >> +     NL4_NAME                = 1,
> >> +     NL4_URL                 = 2,
> >> +     NL4_NETADDR             = 3,
> >> +};
> >> +
> >> +struct nl4_server {
> >> +     enum netloc_type4       nl4_type;
> >> +     union {
> >> +             struct { /* NL4_NAME, NL4_URL */
> >> +                     int     nl4_str_sz;
> >> +                     char    nl4_str[NFS4_OPAQUE_LIMIT + 1];
> >> +             };
> >> +             struct nfs42_netaddr    nl4_addr; /* NL4_NETADDR */
> >> +     } u;
> >> +};
> >> +
> >> +/*  support 1 nl4_server for now */
> >> +#define NFS42_MAX_SSC_SRC       1
> >
> > In that case, let's just build that assumption into the data structures
> > and embed struct nl4_server in nl4_servers and drop the unnecessary
> > kmalloc()s.
> 
> Wouldn't we still want to malloc as the structure is too big to be
> allocated on the stack?

Is it allocated on the stack?  I thought it was embedded in
nfsd4_compoundargs.

Anyway, I'm not that fixated on removing kmalloc()'s, it's OK if you
need them.

Looking at that definition again, NFS4_OPAQUE_LIMIT is 1K, that's bigger
than I'd want embedded in nfsd4_compoundargs too, so yes, it might still
be worth kmalloc()'ing.  Or consider whether we really need the maximum
size for our current use (just ascii-encoded IP addresses?), or whether
we should do the parsing earlier and just store the resulting socket
address.

> Anna has also suggested dropping nl4_servers since the code sets maximum to 1.
> I have resisted making the change because I felt like it was easier to
> increase the
> MAX_SSC_SRC to say something like 10 and support a multi-home server. Then
> the destination server can add smarts to chose between the available address to
> connect to the source server with.
> 
> Is this not a good argument to keep the structures? Should I change
> value to 2 to
> indicate desire to support multi-path?

In the first version of this patchset I recommend dropping anything
that's not necessary.

It's easy enough to add this back in later.  The hard part is going to
be getting in any server-to-server patches at all, so we need to make
them as simple as possible.

The only reason to keep this in the initial version, I think, would be
if you think it's an important enough feature that server-to-server copy
isn't useful at all without it.

--b.
