Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10232 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757001Ab1ETTPf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 May 2011 15:15:35 -0400
Subject: Re: 2.6.38.6 - state manager constantly respawns
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Dr. J. Bruce Fields" <bfields@fieldses.org>
Cc: Harry Edmon <harry@uw.edu>, Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org
Date: Fri, 20 May 2011 15:15:33 -0400
In-Reply-To: <20110520185935.GC11670@fieldses.org>
References: <4DD17CB5.7010009@uw.edu>
	 <1305575007.19725.3.camel@lade.trondhjem.org> <4DD17F79.305@uw.edu>
	 <1305575656.19725.9.camel@lade.trondhjem.org>
	 <20110516202059.GC1680@fieldses.org> <20110516205351.GD1680@fieldses.org>
	 <4DD694DF.2060302@uw.edu> <20110520172639.GA11670@fieldses.org>
	 <1305913963.12712.6.camel@lade.trondhjem.org>
	 <1305916616.14253.1.camel@lade.trondhjem.org>
	 <20110520185935.GC11670@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1305918933.14253.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-05-20 at 14:59 -0400, Dr. J. Bruce Fields wrote: 
> > Bruce,
> > 
> > If the clientid expired, is it possible that the server may have handed
> > out the same numerical short clientid to someone else and that explains
> > why the RENEW is succeeding?
> 
> Clientid's are created from a u32 counter that's sampled only under the
> state lock, so it sounds unlikely.
> 
> I think more likely would be some bug affecting the lifetime of a
> stateid--e.g. if the server destroyed a lock stateid earlier than it
> should in some case, then this would happen.  (Since, as I say, we
> assume EXPIRED for any stateid we don't recognize.)

Shouldn't that be a NFS4ERR_BAD_STATEID instead of NFS4ERR_EXPIRED? The
latter should really be reserved for the case where you know that this
stateid came from an expired lease.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

