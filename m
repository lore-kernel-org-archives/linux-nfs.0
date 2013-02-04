Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:36504 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188Ab3BDOwT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 09:52:19 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: RE: [PATCH] sunrpc: copy scope ID in __rpc_copy_addr6
Date: Mon, 4 Feb 2013 14:52:16 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91835B4C4@SACEXCMBX04-PRD.hq.netapp.com>
References: <1359983408-28337-1-git-send-email-jlayton@redhat.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91835B2E9@SACEXCMBX04-PRD.hq.netapp.com>
 <20130204094204.24c6f9a5@tlielax.poochiereds.net>
In-Reply-To: <20130204094204.24c6f9a5@tlielax.poochiereds.net>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@redhat.com]
> Sent: Monday, February 04, 2013 9:42 AM
> To: Myklebust, Trond
> Cc: bfields@fieldses.org; linux-nfs@vger.kernel.org; chuck.lever@oracle.com
> Subject: Re: [PATCH] sunrpc: copy scope ID in __rpc_copy_addr6
> 
> On Mon, 4 Feb 2013 14:22:47 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > > -----Original Message-----
> > > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > > owner@vger.kernel.org] On Behalf Of Jeff Layton
> > > Sent: Monday, February 04, 2013 8:10 AM
> > > To: bfields@fieldses.org
> > > Cc: linux-nfs@vger.kernel.org; chuck.lever@oracle.com
> > > Subject: [PATCH] sunrpc: copy scope ID in __rpc_copy_addr6
> > >
> > > When copying an address, we should also copy the scopeid in the
> > > event that this is a link-local address and the scope matters.
> > >
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > ---
> > >  include/linux/sunrpc/clnt.h | 1 +
> > >  1 file changed, 1 insertion(+)
> > >
> > > diff --git a/include/linux/sunrpc/clnt.h
> > > b/include/linux/sunrpc/clnt.h index
> > > 47354a2..6a7c261 100644
> > > --- a/include/linux/sunrpc/clnt.h
> > > +++ b/include/linux/sunrpc/clnt.h
> > > @@ -242,6 +242,7 @@ static inline bool __rpc_copy_addr6(struct
> > > sockaddr *dst,
> > >
> > >  	dsin6->sin6_family = ssin6->sin6_family;
> > >  	dsin6->sin6_addr = ssin6->sin6_addr;
> > > +	dsin6->sin6_scope_id = ssin6->sin6_scope_id;
> > >  	return true;
> > >  }
> > >  #else	/* !(IS_ENABLED(CONFIG_IPV6) */
> > > --
> >
> >
> > Can we please move these helpers into a separate header, say
> include/Linux/sunrpc/inet.h?
> >
> 
> Yes, that's long overdue. I'll spin up a patch on top of this one to do that. I'd
> suggest that we call it "addr.h" to keep it in parity with the "addr.c" file that's
> in the sunrpc directory, since we'll need to move the prototypes for those
> functions as well.
> 
> > Oh... Also note that you probably want to apply the above scopeid to the
> NFSv4 callback address that is supplied by the client in the setclientid call.
> >
> 
> I'm not clear on what you mean here. This patch should make it so that the
> server keeps the correct scopeid along with the cb address that it tracks for a
> client (something that I don't think it does properly today).
> 
I mean that the NFSv4 client supplies an address in "universal address" format (i.e. a string) as part of the setclientid call. If that address is a link-local address, then it won't contain a scopeid ('cos the scopeid is an identifier that is local to the _server_). In that case the server should apply the scopeid from the nfs4_clientid in the gen_callback() helper.

Cheers
  Trond

