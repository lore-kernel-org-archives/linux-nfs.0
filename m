Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:34053 "EHLO lists.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421Ab0GVSHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 14:07:52 -0400
Date: Thu, 22 Jul 2010 11:07:51 -0700
From: Jeremy Allison <jra@samba.org>
To: Volker Lendecke <Volker.Lendecke@SerNet.DE>
Cc: Jeremy Allison <jra@samba.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        David Howells <dhowells@redhat.com>,
        Jan Engelhardt <jengelh@medozas.de>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended  file stats available [ver #6]
Message-ID: <20100722180751.GC32008@samba1>
Reply-To: Jeremy Allison <jra@samba.org>
References: <30448.1279800887@redhat.com>
 <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
 <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
 <20100722162712.GB10352@jeremy-laptop>
 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
 <1279817930.3621.14.camel@heimdal.trondhjem.org>
 <20100722180204.GA32008@samba1>
 <E1Oc08W-00CZuz-Ns@intern.SerNet.DE>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E1Oc08W-00CZuz-Ns@intern.SerNet.DE>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 08:04:41PM +0200, Volker Lendecke wrote:
> On Thu, Jul 22, 2010 at 11:02:04AM -0700, Jeremy Allison wrote:
> > On Thu, Jul 22, 2010 at 12:58:50PM -0400, Trond Myklebust wrote:
> > > 
> > > That would make it impossible to export the filesystem with NFSv2 and
> > > v3. They do rely on ctime checking for certain operations (e.g. deciding
> > > when to invalidate access and acl caches). NFSv4 needs this too if the
> > > filesystem has no dedicated change attribute.
> > > 
> > > Still, I suppose the market for exporting the same filesystem with both
> > > NFS and Samba is limited...
> > 
> > Ask NetApp about that :-). They have built a rather large
> > business on just that fact :-).
> 
> Jeremy, how many hours have you spent getting "posix
> locking" to the point where it is now? :-)
> 
> Volker
> 
> P.S: For those not aware, "posix locking = yes" is
> cross-protocol byte range locking done by smbd to co-operate
> with local processes and NFS.

The time is counted in years, not hours :-).
