Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11136 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755070Ab1HCM12 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 08:27:28 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: State of NFSv4 VolatileFilehandles
Date: Wed, 3 Aug 2011 05:27:26 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778B9B@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <4E38F894.4070003@linux.vnet.ibm.com>
References: <4E37E66D.90102@linux.vnet.ibm.com> <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com> <4E38F894.4070003@linux.vnet.ibm.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Venkateswararao Jujjuri" <jvrao@linux.vnet.ibm.com>,
        "Chuck Lever" <chuck.lever@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Venkateswararao Jujjuri [mailto:jvrao@linux.vnet.ibm.com]
> Sent: Wednesday, August 03, 2011 3:28 AM
> To: Chuck Lever
> Cc: linux-nfs@vger.kernel.org; Myklebust, Trond
> Subject: Re: State of NFSv4 VolatileFilehandles
> 
> On 08/02/2011 07:53 AM, Chuck Lever wrote:
> > On Aug 2, 2011, at 7:58 AM, Venkateswararao Jujjuri wrote:
> >
> >> We at IBM receiving multiple customer requests for supporting NFSv4
> server migration.
> >> I have referred to Trond and Chuck's presentations at 2011
> Connectathon and there appears to be
> >> sizable work remaining. I am not sure if there is any progress made
> since those talks.
> >>
> >> I would like to open up a discussion thread on the mailing list to
> understand the latest status.
> >> Also would like to get the input on the Volatile Filehandles (VFH).
> I searched the mailing list, and could not
> >> find any recent discussion on this.
> >>
> >> Some discussion points:
> >> - What are the pieces left to attain full client/server support for
> seamless server migration?
> > The client migration implementation is code complete and in test
now.
> This includes both minor version 0 and 1.  We don't have any mv1
> servers to test with at this time, so that support is provisional.  I
> hope to have patches ready for the 3.2 merge window, but you can see
> what I've got now on git.linux-nfs.org.
> Great I will take it from there. Is it your branch or Trand's ? Can
you
> please give me which project/branch
> I should take from git.linux-nfs.org?
> >
> > A problem is that there are corner cases in the v4.0 migration
> specification that are still unresolved.  We are working with the
NFSv4
> WG to get these addressed.  But I expect some minor changes even after
> the patches are merged upstream.
> What are those corner cases? Is it on any mailing list? Is it possible
> for us to see that discussion?
> >
> > We don't have firm plans for a server migration implementation on
> Linux at this time, but Bruce can maybe say more about that.
> Sure; would wait for Bruce's views on this. We are getting
requirements
> for both client and server support.
> 
> >> - Any discussion/sugestions on the way to implement VFH?  As
> described in RFC 3530 sections 4.2.3 and 4.2.4?
> > I think we are avoiding volatile file handles as long as possible.
> We don't have plans to implement them at the moment.
> Hrm. How can we achieve the complete migration support without
volatile
> filehandle support?
> What are the reasons for avoiding it? May be we can start looking into
> this but would like to understand
> the reasons (if any) for avoiding it.

POSIX allows the namespace to change at any time (rename() or unlink())
and so you cannot rely on addressing files by pathname. That was the
whole reason for introducing filehandles into NFSv2 in the first place.

Volatile filehandles were introduced in NFSv4 without any attempt to fix
those shortcomings. There is no real prescription for how to recover in
a situation where a rename or unlink has occurred prior to the
filehandle expiring. Nor is there a reliable prescription for dealing
with the case where a new file of the same name has replaced the
original.
Basically, the implication is that volatile filehandles are only really
usable in a situation where the whole Filesystem is read-only on the
server.

Cheers
  Trond
