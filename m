Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55142 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935300Ab3DPBsh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Apr 2013 21:48:37 -0400
Date: Mon, 15 Apr 2013 21:48:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] unsupported mandatory server features
Message-ID: <20130416014833.GB27667@fieldses.org>
References: <20130412210100.GP7081@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA92871330A@SACEXCMBX04-PRD.hq.netapp.com>
 <20130412220642.GQ7081@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130412220642.GQ7081@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 12, 2013 at 06:06:42PM -0400, J. Bruce Fields wrote:
> On Fri, Apr 12, 2013 at 09:49:39PM +0000, Myklebust, Trond wrote:
> > > -----Original Message-----
> > > From: nfsv4-bounces@ietf.org [mailto:nfsv4-bounces@ietf.org] On Behalf
> > > Of J. Bruce Fields
> > > Sent: Friday, April 12, 2013 5:01 PM
> > > To: nfsv4@ietf.org
> > > Cc: linux-nfs@vger.kernel.org
> > > Subject: [nfsv4] unsupported mandatory server features
> > > 
> > > I'm expecting to turn on basic 4.1 support by default on the Linux server
> > > before supporting two mandatory 4.1 features, and looking for advice on
> > > handling that without too much pain to future clients.  I suspect I'm not the
> > > only server in this situation; anyone know what others are doing?
> > > 
> > > The features are:
> > > 
> > > 	- State protection (SSV and MACH_CRED): I'm currently returning
> > > 	  SERVERFAULT on EXCHANGE_ID's that request this, but this isn't
> > > 	  really what SERVERFAULT is for.
> > > 
> > > 	  I'm inclined to switch to ENC_ALG_UNSUPP; that leaves future
> > > 	  clients unable to distinguish between servers lacking SSV
> > > 	  entirely from those lacking support for a particular
> > > 	  algorithm, but in practice I think they'd handle both in the
> > > 	  same way anyway.
> > 
> > Why not just reply with NFS4ERR_ENC_ALG_UNSUPP for SP4_SSV (as you suggest) and return an empty spo_must_allow, and minimal spo_must_enforce sets for SP4_MACH_CRED?
> > 
> > By minimal spo_must_enforce, I mean EXCHANGE_ID, CREATE_SESSION, DESTROY_SESSION, BIND_CONN_TO_SESSION, and DESTROY_CLIENTID. I'm assuming that you default to checking the principal name for those anyway since NFSv4 requires it for the corresponding SETCLIENTID/CONFIRM?
> 
> Yes, I think you're right, I'll try that now!

OK, OK, so the minimal SP4_MACH_CRED implementation is a lot easier than
I thought:

fs/nfsd/nfs4state.c |   62 ++++++++++++++++++++++++++++++++++++++++++---------
fs/nfsd/nfs4xdr.c   |    2 +-
fs/nfsd/state.h     |    1 +
3 files changed, 53 insertions(+), 12 deletions(-)

> > > 	- GSS on the backchannel: currently CREATE_SESSION or
> > > 	  BACKCHANNEL_CTL will succeed but SEQUENCE will start returning
> > > 	  with the CB_DOWN flag set.  I would rather return an error
> > > 	  immediately than make the client guess what's going on in
> > > 	  recovery.
> > > 
> > > 	  Could I get away with returning ENC_ALG_UNSUPP here too?  It's
> > > 	  not entirely logical, but it's also currently illegal for
> > > 	  these two operations so its use wouldn't be confused with some
> > > 	  other.
> > 
> > Why not return NFS4ERR_NOENT to tell the client that the handle does not exist?

I'm still inclined to return a new error here, though; NOENT seems
already taken for something a client would handle a bit differently.

--b.

> 
> Imagine a client and server both support gss on the backchannel.  The
> most likely cause I can think of (bugs aside) for a NFS4ERR_NOENT return
> in that case is that the server just purged that context from its cache
> for some reason.  It would then seem reasonable for the client to
> attempt to recover by establishing a new context and resending with the
> new handle.
> 
> How would the client distinguish between that case and "sorry, gss on
> the backchannel will never work"?
> 
> I guess if the server was replying NOENT to a handle over which that
> very call was sent then maybe it'd be safe for the client to assume the
> latter case.
> 
> It seems a little subtle.
