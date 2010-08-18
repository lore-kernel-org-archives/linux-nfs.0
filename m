Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:47229 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752570Ab0HRTXS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 15:23:18 -0400
Subject: Re: [PATCH 0/2] Support for Numeric Representations of UIDs and
 GIDs.
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <4C6C3000.5010003@RedHat.com>
References: <1282073925-18707-1-git-send-email-steved@redhat.com>
	 <20100818182053.GB13050@fieldses.org>  <4C6C3000.5010003@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 Aug 2010 15:23:11 -0400
Message-ID: <1282159391.8540.90.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-08-18 at 15:09 -0400, Steve Dickson wrote:
> 
> On 08/18/2010 02:20 PM, J. Bruce Fields wrote:
> > On Tue, Aug 17, 2010 at 03:38:43PM -0400, Steve Dickson wrote:
> >> In recent NFS v2/v3 to v4 transitions, one of the sticking 
> >> points have been that fact v4 uses strings in the format
> >> of "user@domain" instead of 32bit integers for uids and 
> >> gids.
> >>
> >> When the string can not be mapped, its mapped to the 'nobody'
> >> user which is not optimal for things like backup servers and
> >> such where the ids will not be know by both sides.
> >>
> >> So this patch series enables the server to send out numeric 
> >> string of uids and gids that do not have the '@domain' part.
> >> The series also adds functionality to the client that parse these
> >> type of strings and will use the numeric representation
> >> of the ids iff the id exists on the client, which is 
> >> sightly different that Solaris. Solaris dose not have that
> >> "id must exist" restriction.
> > 
> > Why did you decide to impose that restriction?
> I just thought it made sense, from a security standpoint to make sure the 
> ids were at least valid on the client... if they are not valid the id 
> becomes 'nobody' which how it works today... but is different than how 
> OpenSolaris does it... they just use whatever the server tells to... 

As I read RFC3530, the recommendation is that the server SHOULD reject
an attempt by the client to use numeric ids if it knows of a valid
name@domain mapping for that uid or gid.

The client has no such restriction. It probably should just accept the
numeric uid or gid if that is what the server supplies.

Cheers
  Trond

