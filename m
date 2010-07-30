Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:56850 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760085Ab0G3SMN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jul 2010 14:12:13 -0400
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Phil Pishioneri <pgp@psu.edu>
Cc: Volker.Lendecke@SerNet.DE, Jeremy Allison <jra@samba.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
In-Reply-To: <4C5311F4.2050100@psu.edu>
References: <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	 <30448.1279800887@redhat.com> <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
	 <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	 <20100722162712.GB10352@jeremy-laptop>
	 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
	 <1279817930.3621.14.camel@heimdal.trondhjem.org>
	 <20100722180204.GA32008@samba1>  <E1Oc08W-00CZuz-Ns@intern.SerNet.DE>
	 <1279825160.3621.71.camel@heimdal.trondhjem.org> <4C5311F4.2050100@psu.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 30 Jul 2010 14:11:46 -0400
Message-ID: <1280513506.12852.22.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-07-30 at 13:55 -0400, Phil Pishioneri wrote:
> On 7/22/10 2:59 PM, Trond Myklebust wrote:
> > The fact remains that most of us would be hard pressed to name an
> > application
> 
> Microsoft Office?
> 
> > that requires you to share the same dataset to both
> > Windows/CIFS and posix NFS clients.
> 
> NFS client: Mac OS X (NFSv3, since v4 on it is still alpha *cough*).
> 
> > tends to discourage mixing the two environments.
> 
> Or is "discourage" not strong enough term to describe that we shouldn't 
> be doing this?
> 
> -Phil

Your Mac has a perfectly functional CIFS client, as do your Linux boxes.
They both interoperate just fine with Samba, and would presumably
continue to do so if someone were to decide to reuse the ctime field on
your Samba box as storage for a create time.

  Trond

