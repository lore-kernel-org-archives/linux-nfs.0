Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38057 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852Ab3HZV2L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Aug 2013 17:28:11 -0400
Date: Mon, 26 Aug 2013 17:28:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Simo Sorce <simo@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, Jan Stancek <jstancek@redhat.com>
Subject: Re: [PATCH v3] SUNRPC: Ensure that the RPCSEC_GSS daemon uses the
 correct service names
Message-ID: <20130826212805.GB14809@fieldses.org>
References: <1377202213-5031-1-git-send-email-jlayton@redhat.com>
 <1377320162.2814.331.camel@willson.li.ssimo.org>
 <20130824065706.7bf780e8@tlielax.poochiereds.net>
 <20130824124233.GC18084@fieldses.org>
 <20130826165051.GF3121@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130826165051.GF3121@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 26, 2013 at 12:50:51PM -0400, J. Bruce Fields wrote:
> On Sat, Aug 24, 2013 at 08:42:33AM -0400, J. Bruce Fields wrote:
> > On Sat, Aug 24, 2013 at 06:57:06AM -0400, Jeff Layton wrote:
> > > On Sat, 24 Aug 2013 00:56:02 -0400
> > > Simo Sorce <simo@redhat.com> wrote:
> > > 
> > > > On Thu, 2013-08-22 at 16:10 -0400, Jeff Layton wrote:
> > > > > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > > 
> > > > > v2: added pipe_dir_name field to nfsacl program to fix v3+krb5
> > > > >     (Should we add pipe_dir_name fields to other programs too?).
> > > > > 
> > > > > v3: Drop changes to gss_encode_v1_msg. They don't seem to be
> > > > >     needed since gssd scrapes that out of the "info" file.
> > > > > 
> > > > > Fix the upcalls to use the right service names for gssd.  The old
> > > > > version of the rpc.gssd upcall expects the service name to be either
> > > > > "nfs" or "nfs4_cb", which it will then concatenate with the server name
> > > > > to create a target name of nfs@<server> or nfs4_cb@<server>
> > > > 
> > > > I've never seen anyone deply keytabs with nfs4_cb/fqdn service names,
> > > > what are you trying to do here exactly ?
> > > > 
> > > > Afaik the only service names used historically have been host/ and nfs/
> > > > and in some rare cases root/
> > > > 
> > > > Also the patch seem to add a bunch of other 'service' names ? If you are
> > > > going to kerberize those services are you going to expect admins to drop
> > > > multiple keys down in the keytabs ? What is the exact intent here ?
> 
> Yeah, that seems wrong to me, if (big if) any of the other services used
> gss I'd expect they'd want to authenticate to the same nfs/ principal.
> 
> > > Mostly, I'm trying to ensure that the nfsacl service uses a nfs/
> > > principal to fix the immediate pain point that nfsv3+krb5 doesn't work.
> > > With the rest, I was mainly trusting that Trond knew what he was
> > > doing. ;)
> > > 
> > > I agree though...I've never seen a nfs4_cb/ principal in use, and I'm
> > > not sure that we'd really get a lot of value from using a separate
> > > principal for callbacks.
> > 
> > It's wrong, in fact: an NFSv4.0 callback is supposed to authenticate to
> > the principal that performed the setclientid.
> 
> Well, but: after refamiliarizing myself with the code this morning:
> really, it's irrelevant.  The server's setup_callback_client() calls
> rpc_create with client_name set to the principal that performed the
> setclientid.  This sets cl_principal, which results in a "target="
> argument in the upcall.
> 
> (The way this is set looks hairy:
> 
> 	- svcgssd case: svcgssd passes it down at the end of the
> 	  downcall.  It's calculated by
> 	  utils/gssd/svcgssd_proc.c:get_hostbased_client_name by calling
> 	  gss_display_name() and then changing x/y@REALM to x@y in the
> 	  krb5 case.  ??
> 	- gssproxy case: does the same transformation on the returned
> 	  name in gssp_accept_sec_context_upcall.
> 
> But Simo'd be the expert on whether this makes sense and what we should
> do instead if not.)

And actually as far as I can tell NFSv4.0 callbacks aren't working at
all right now over krb5.  I see gssd open the info file and then never
read any upcalls, so I wonder if it's just balking at something it sees
in the info file.

--b.
