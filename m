From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: Change default behavior when "sec=" is not
	specified by user
Date: Tue, 1 Sep 2009 16:05:09 -0400
Message-ID: <20090901200509.GE27726@fieldses.org>
References: <18678BB3-52C6-4376-BBD1-50B8947BAAC7@oracle.com> <20090901160914.GG22846@fieldses.org> <73E8EAAF-9164-4F78-A9D4-1CC86A6A6255@oracle.com> <20090901163846.GJ22846@fieldses.org> <B9CADBA9-54B0-44AD-A8DC-FE3ED63341BC@oracle.com> <4A9D690E.2050704@redhat.com> <20090901185011.GC27726@fieldses.org> <4A9D6D7C.60501@redhat.com> <20090901191652.GD27726@fieldses.org> <4A9D74D6.7000608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59714 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754022AbZIAUFQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 16:05:16 -0400
In-Reply-To: <4A9D74D6.7000608@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 01, 2009 at 03:24:06PM -0400, Peter Staubach wrote:
> J. Bruce Fields wrote:
> > On Tue, Sep 01, 2009 at 02:52:44PM -0400, Peter Staubach wrote:
> >> J. Bruce Fields wrote:
> >>> On Tue, Sep 01, 2009 at 02:33:50PM -0400, Peter Staubach wrote:
> >>>> Some servers will accept any flavor of incoming RPC security
> >>>> and just use AUTH_NULL in this situation.  It really shouldn't
> >>>> matter what the client sends, as long as the server is just
> >>>> going to map all requests to nobody/nobody anyway...
> >>> OK, but let's not pile on more workarounds than we have to.  I don't see
> >>> any reason that we really need to do anything special for servers that
> >>> are broken in *that* particular way....
> >>>
> >> I don't think that that is considered to be broken, by the way.
> > 
> > OK, maybe not.
> > 
> >> I am not sure whether it still works this way, but I know that
> >> Solaris used to work this way, at the very least.
> >>
> >> Since I clearly haven't looked, but why would the Linux NFS
> >> server care which flavor that it got sent, if the export is
> >> configured to map all requests to nobody/nobody?
> > 
> > I can think of any number of reasons, but on the client side I don't see
> > any great advantage to taking "auth_null" to mean "use anything you
> > want": it's another special case, it's undocumented and will only work
> > on some servers, and if it's really what the administrator wants, it
> > should be easy to fix the server to advertise everything while still
> > doing the id-squashing.
> > 
> 
> I don't understand this last.  Why would the server bother to
> advertise the various flavors if they are all going to treated
> as if they were AUTH_NONE?

There's a huge difference between the security characteristics of
AUTH_NONE and AUTH_GSS, even when the latter is id-squashed.

The security flavor list is meant to advertise acceptable security
flavors, not the server's id-mapping configuration.

(But I might understand the more limited case of treating auth_none and
auth_sys the same.)

> It would seem to violate expectations
> that clients may have, that they issued authentic and verifiable
> requests, only to be treated as if they were not?
> 
> Just out of curiosity, any number of reasons?  :-)

The server might simply not have support for AUTH_GSS: krb5 might not be
completely set up, or whatever, in which case it's simpler to refuse
those security flavors right away rather than to, say, risk waiting for
a timeout somewhere.

Or maybe the krb5 negotiation imposes undesireable load somewhere.

> This all seems like a lot of conversation and work just to try
> to figure out how to accommodate a configuration which has
> already indicated that it will ignore any incoming authentication
> information.  I would suggest that we take the easy and obvious
> way of sending AUTH_UNIX to such systems and if we find one that
> really insists upon receiving AUTH_NONE from the client, then
> we fix the client.

I believe a recent linux server, at least, will only accept auth_none if
that's all it advertises.  That behavior seemed, well, easy and obvious.

We could change it to treat auth_none and auth_sys interchangeably.  But
there'd still be servers out there with that behavior.  And I don't see
any advantage to the client to using auth_sys in this particular case.

--b.
