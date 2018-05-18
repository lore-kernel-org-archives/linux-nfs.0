Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52828 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751009AbeERRHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 May 2018 13:07:52 -0400
Message-ID: <1526663271.10011.14.camel@redhat.com>
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
From: Simo Sorce <simo@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Fri, 18 May 2018 13:07:51 -0400
In-Reply-To: <1DA998A5-B4D5-4FD3-B557-9B4DCD43879B@oracle.com>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
         <1526659388.10011.10.camel@redhat.com>
         <1DA998A5-B4D5-4FD3-B557-9B4DCD43879B@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2018-05-18 at 12:53 -0400, Chuck Lever wrote:
> > On May 18, 2018, at 12:03 PM, Simo Sorce <simo@redhat.com> wrote:
> > 
> > On Fri, 2018-05-18 at 11:39 -0400, Chuck Lever wrote:
> > > I've been experimenting with this series that modifies NFSD to
> > > discover and use the correct GSS service principal when constructing
> > > its NFSv4.0 callback channels. I'm interested in review of this
> > > approach. There are a couple of code comments marked with XXX that
> > > also need some attention.
> > > 
> > > The rpc.gssd change mentioned in 1/4 is unremarkable and will be
> > > made available once there is consensus about the kernel changes
> > > in this series. No gssproxy changes are necessary.
> > > 
> > > ---
> > > 
> > > Chuck Lever (4):
> > >      sunrpc: Enable the kernel to specify the hostname part of service principals
> > >      sunrpc: Extract target name into svc_cred
> > >      nfsd: Use correct credential for NFSv4.0 callback with GSS
> > >      nfsd: Remove callback_cred
> > > 
> > > 
> > > fs/nfsd/nfs4callback.c               |   29 ++++----------
> > > fs/nfsd/nfs4state.c                  |   17 +++-----
> > > fs/nfsd/state.h                      |    2 -
> > > include/linux/sunrpc/svcauth.h       |    3 +
> > > net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
> > > net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 ++++++++++++++++++++++------------
> > > 6 files changed, 80 insertions(+), 61 deletions(-)
> > > 
> > > --
> > > Chuck Lever
> > 
> > Ack for the sunrpc gssp changes.
> 
> Thanks!
> 
> 
> > The one thing I am unsure of is whether always using the source name
> > as the callback target is going to work properly, and what happens
> > when it is not.
> 
> The series does not change the client principals in play, it
> merely ensures that the source principal the server uses to call
> the client back will match the principal the client used to
> establish the GSS context for the forward channel. It doesn't
> seem to me like that would make any case worse (unless there are
> bugs, of course).
> 
> The forward channel GSS context can be established only if the
> client chooses a target principal that has a key in the server's
> keytab already. So the server was choosing the wrong key for the
> callback channel in some cases before, but now will be choosing
> a source principal that the client is already aware of and should
> expect.
> 
> The server will continue to use a target principal for the
> callback channel that the client provided when it authenticated.

This is fine, I am in fact ok with the changes there.

> 
> > Machines mounting with NFSv4.0 but without machine credentials (ie:
> > root kinits to admin@FOO.BAR and uses those creds to mount) will
> > always fail to establish a callback because the NFS client's kernel
> > does not have access to the user long term key. So even if the KDC
> > would decide to allow you to get a ticket for a user principal, the
> > client would not be able to complete context establishment.
> 
> This might be a little outside the scope of my series.
> 
> I think currently the server will test the callback channel when
> the client first OPENs a file, and it will not offer a delegation
> if the channel cannot be established. So what we need here is a
> reliably quick failure in the cases that will not work. That will
> enable the first OPEN to proceed without undue delay.

If this is an ok degradation for clients that use "unexpected"
credentials to mount, I am ok with that.

> My mount point was hanging here, but I'm not sure why. I was
> focused on addressing the authentication mismatch, which fixed
> the hang, but perhaps there's another bug.

I was just mentioning that callback calls may fail, but as long as that
is a supportable situation we are probably ok (assuming that doesn't
cause hangs of course).

> > Maybe a fallback behavior where it tries to guess at a possible
> > machine service name would be valuable for cases where a machine
> > credential is actually available on the client host even though
> > for whatever reason the mount was done using some user credential.
> 
> We could pick a few likely candidates for the server to try if
> the client-provided target principal does not work for the callback
> channel, but I wonder if that is an heroic effort that is not worth
> the additional complexity.

I do not know that it is worth, proper logging (so admins can
understand what is going on and fix their clients) may be sufficient.

> Is it impossible to give the client's kernel access to that user
> key for the callback channel?

No, not in the general case. The long term key is the user's kerberos
password in the simple case, and sometimes may not even exist. No key
may be stored in the KDC database when Pkinit (smartcards) are used or
in some cases Pass+OTP forwarded to external servers, etc... 

> Alternately, using NFSv4.1 might be helpful.

Yes, 4.1 is better.

> Also, in the user credential-only case would the client even use
> GSS for lease management. If it does not, then the server would
> use AUTH_UNIX and not GSS for NFSv4.0 callbacks.

I am not sure why it couldn't, but there is some "arbitrary" principal
selection in some of the gss code in NFS, so I do not have a good
answer here without carefully looking at the client code.

Simo.

-- 
Simo Sorce
Sr. Principal Software Engineer
Red Hat, Inc

