Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39300 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751156AbeERUkA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 May 2018 16:40:00 -0400
Message-ID: <1526675998.10011.27.camel@redhat.com>
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
From: Simo Sorce <simo@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Fri, 18 May 2018 16:39:58 -0400
In-Reply-To: <CAN-5tyFs4nxAwVynpr=Q5d_t+N5s9sa=2+1mj4-pZ-m1Xe3ZRA@mail.gmail.com>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
         <CAN-5tyGDGOqPKXKD+LQq8Ub3CUosmaaAq=ir3Gp7R3LKABwtEQ@mail.gmail.com>
         <DB8E23EF-80A4-48D0-B53C-AD2A4B0076E2@oracle.com>
         <CAN-5tyFs4nxAwVynpr=Q5d_t+N5s9sa=2+1mj4-pZ-m1Xe3ZRA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2018-05-18 at 16:11 -0400, Olga Kornievskaia wrote:
> On Fri, May 18, 2018 at 3:23 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> > 
> > > On May 18, 2018, at 2:53 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> > > 
> > > Hi Chuck,
> > > 
> > > I'm not convinced that "srchost=" is necessary. I believe that
> > > everything that is needed is suppose to be encoded in the "target="
> > > option.
> > 
> > I don't believe target= has what we want. For NFSv4.0 callback:
> > 
> >   A. The callback source principal needs to be the same as the client's
> >      NFS server target principal.
> 
> Correct and by specifying "nfs" and "*" I think that signals to the
> gssd to pick the NFS server principal (which is what the client would
> used as the target for the client to server authentication).
> 
> >   B. The callback target principal needs to be the same as the client's
> >      NFS server source principal.
> > 
> > Today, for NFSv4.0 callbacks, the kernel passes to gssd:
> > 
> >   target= it uses B for this
> > 
> >   service= it always sets this to "nfs"
> > 
> > And gssd "makes up" the hostname part of A using gethostname(3), which
> > is bogus for multi-homed NFS servers.
> 
> I agree that's bogus. Instead we should grab the domain from the
> "target=" string.
> 
> 
> > So my patch series does the following for NFSv4.0 callbacks:
> > 
> > 1. It acquires the actual target principal the client used to establish
> >    it's lease. This is A above.
> > 
> > 2. Instead of always passing "nfs" as the service= value, it passes
> >    the non-hostname part of A. That should be "nfs" but it doesn't
> >    have to be.
> 
> Ok so yes it has historically have always been "nfs" (even thought
> it's only RECOMMENDED by the spec) and I don't think this is the case
> to add complexity to change a well established behavior?

Not so well established, historically "host/" has been used as well.

> > 3. Instead of letting gssd make up the hostname part of the source
> >    principal, it passes the hostname part of A.
> 
> I'm arguing that hostname part of A should have been a part of the "target="

You can't use the target name for the source, I do not understand this
comment.

The problem here is that you need to know what server name the client
used.

If the server is multihomed and has three keys in the keytab:
nfs/a.nfs.domain
nfs/b.nfs.domain
nfs/c.nfs.domain

you need to know which creds to acquire in gssd in order to connect
back to the client with the "right" ones.

What is "right" depends on what the client (nfs/client.domain) used to
connect to you, and that is not in target= 

HTH,
Simo.

> > 
> > That should provide the correct source principal in the multi-home
> > case, and it should be backwards-compatible with older gssd's.
> > 
> > 
> > Now here's why it's not enough to use getsockname(3) on target=
> > to predict the correct source hostname:
> > 
> > If the client has established the lease when mounting from one
> > particular hostname, and then mounts from another, it will have
> > to continue managing the lease using the principal it has already
> > established with the first hostname. NFSD knows what that is, and
> > can tell gssd what it needs to be. gssd, using only getsockname(3),
> > would probably pick something that is wrong.
> > 
> > 
> > > I thought target just needed to correctly identify the domain for
> > > which authentication is taking place.
> > 
> > That's what srchost= does. We can call it something else if that
> > helps.
> > 
> > 
> > > Then I think more changes should
> > > be in nfs-utils to make sure that we find credentials for that
> > > particular domain instead of going by the gethostbyname() results.
> > 
> > That's a patch to gssd that I didn't post. I will post that later if
> > we all agree srchost= is OK.
> > 
> > srchost= is optional. If it's not present in the upcall, gssd will
> > continue to use the result of gethostname(3) to construct the source
> > principal.
> > 
> > 
> > > On Fri, May 18, 2018 at 11:39 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > > > I've been experimenting with this series that modifies NFSD to
> > > > discover and use the correct GSS service principal when constructing
> > > > its NFSv4.0 callback channels. I'm interested in review of this
> > > > approach. There are a couple of code comments marked with XXX that
> > > > also need some attention.
> > > > 
> > > > The rpc.gssd change mentioned in 1/4 is unremarkable and will be
> > > > made available once there is consensus about the kernel changes
> > > > in this series. No gssproxy changes are necessary.
> > > > 
> > > > ---
> > > > 
> > > > Chuck Lever (4):
> > > >      sunrpc: Enable the kernel to specify the hostname part of service principals
> > > >      sunrpc: Extract target name into svc_cred
> > > >      nfsd: Use correct credential for NFSv4.0 callback with GSS
> > > >      nfsd: Remove callback_cred
> > > > 
> > > > 
> > > > fs/nfsd/nfs4callback.c               |   29 ++++----------
> > > > fs/nfsd/nfs4state.c                  |   17 +++-----
> > > > fs/nfsd/state.h                      |    2 -
> > > > include/linux/sunrpc/svcauth.h       |    3 +
> > > > net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
> > > > net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 ++++++++++++++++++++++------------
> > > > 6 files changed, 80 insertions(+), 61 deletions(-)
> > > > 
> > > > --
> > > > Chuck Lever
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > --
> > Chuck Lever
> > 
> > 
> > 

-- 
Simo Sorce
Sr. Principal Software Engineer
Red Hat, Inc

