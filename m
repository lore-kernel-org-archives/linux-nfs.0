Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56243 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760603Ab3DCO4G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 10:56:06 -0400
Date: Wed, 3 Apr 2013 10:56:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] Document new -z/-Z options
Message-ID: <20130403145603.GA3344@fieldses.org>
References: <515B2F8D.3030302@RedHat.com>
 <1364931149-18484-3-git-send-email-simo@redhat.com>
 <20130403142003.GC13951@fieldses.org>
 <1364999747.10726.3.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364999747.10726.3.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 03, 2013 at 02:35:48PM +0000, Myklebust, Trond wrote:
> On Wed, 2013-04-03 at 10:20 -0400, J. Bruce Fields wrote:
> > On Tue, Apr 02, 2013 at 03:32:29PM -0400, Simo Sorce wrote:
> > > Options are not in alphabetical order but -z/-Z clearly always come last.
> > > 
> > > Signed-off-by: Simo Sorce <simo@redhat.com>
> > > ---
> > >  utils/gssd/gssd.man |   13 ++++++++++++-
> > >  1 files changed, 12 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> > > index 79d9bf91ac6b976c57d167e60d07f828a3ff5b1f..7918c2a0ff76c3918449cf3e1420f0a289929ac1 100644
> > > --- a/utils/gssd/gssd.man
> > > +++ b/utils/gssd/gssd.man
> > > @@ -8,7 +8,7 @@
> > >  rpc.gssd \- RPCSEC_GSS daemon
> > >  .SH SYNOPSIS
> > >  .B rpc.gssd
> > > -.RB [ \-fMnlvr ]
> > > +.RB [ \-fMnlvrzZ ]
> > >  .RB [ \-k
> > >  .IR keytab ]
> > >  .RB [ \-p
> > > @@ -266,6 +266,17 @@ new kernel contexts to be negotiated after
> > >  seconds, which allows changing Kerberos tickets and identities frequently.
> > >  The default is no explicit timeout, which means the kernel context will live
> > >  the lifetime of the Kerberos service ticket used in its creation.
> > > +.TP
> > > +.B -z
> > > +This option tries to avoid DNS Reverse (PTR) lookups for determining the 
> > > +server name to pass to GSSAPI if the name passed at mount point is not an IP 
> > > +address. Currently off by default for compatibility reasons.
> > > +.TP
> > > +.B -Z
> > > +This is the inverse of 
> > > +.B -z
> > > +and forces the use of DNS Reverse resolution of the server's IP address to
> > > +retrieve the server name to use in GSAPI authentication.
> > 
> > By the way I think with the "new" upcall, gssd ignores whatever it got
> > out of the info file if the "target=" parameter is provided in the
> > upcall.
> 
> Correct.
> 
> > (But looking at the code I think that's only used in the nfsv4.0
> > callback case, and isn't worth mentioning here.)
> 
> Wrong. It is also used for NFSv4 and NFSv4.1 state management.
> IOW: SETCLIENTID/RENEW and for NFSv4.1 EXCHANGE_ID/SEQUENCE; anything
> that uses clp->cl_machine_cred.

I was talk about "target=", but I believe you're talking about
"service=".

The former is a server name (myserver.example.com), the latter a service
name (nfs).

--b.
