Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51919 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754661Ab0LOVs5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 16:48:57 -0500
Date: Wed, 15 Dec 2010 16:48:55 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org
Subject: Re: System CPU increasing on idle 2.6.36
Message-ID: <20101215214854.GC9646@fieldses.org>
References: <20101215011021.GA24594@hostway.ca>
 <20101215015609.GB24594@hostway.ca>
 <20101215180813.GA7773@fieldses.org>
 <1292437333.3068.14.camel@heimdal.trondhjem.org>
 <20101215183816.GB7773@fieldses.org>
 <1292441630.3068.55.camel@heimdal.trondhjem.org>
 <20101215194956.GA9646@fieldses.org>
 <1292443028.3068.60.camel@heimdal.trondhjem.org>
 <20101215201908.GB9646@fieldses.org>
 <1292445128.3068.71.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292445128.3068.71.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 15, 2010 at 03:32:08PM -0500, Trond Myklebust wrote:
> On Wed, 2010-12-15 at 15:19 -0500, J. Bruce Fields wrote:
> 
> > Could you give an example of a case in which all of the following are
> > true?:
> > 	- the administrator explicitly requests numeric id's (for
> > 	  example by setting nfs4_disable_idmapping).
> > 	- numeric id's work as long as the client uses auth_sys.
> > 	- they no longer work if that same client switches to krb5.
> 
> Trivially:
> 
> Server /etc/passwd maps trondmy to uid 1000
> Client /etc/passwd maps trondmy to uid 500

I understand that any problematic case would involve different
name<->id mappings on the two sides.

What I don't understand--and apologies if I'm being dense!--is what
sequence of operations exactly would work in this situation if we
automatically switch idmapping based on auth flavor, and would not work
without it.

Are you imagining a future client that is also able to switch auth
flavors on the fly (say, based on whether a krb5 ticket exists or not),
or just unmounting and remounting to change the security flavor?

Are you thinking of creating a file under one flavor and accessing it
under another?

--b.
