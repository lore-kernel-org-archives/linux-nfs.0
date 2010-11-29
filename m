Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55693 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074Ab0K2SXP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 13:23:15 -0500
Subject: Re: NFSv4 behaviour on unknown users
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Spelic <spelic@shiftmail.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4CF3ED05.3070401@shiftmail.org>
References: <4CF3ED05.3070401@shiftmail.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 29 Nov 2010 13:22:55 -0500
Message-ID: <1291054975.12784.17.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-11-29 at 19:12 +0100, Spelic wrote:
> Hello all
> we recently moved to nfsv4 from v3.
> 
> I'm currently using idmapd and not kerberos.
> 
> I noticed that now, with idmapd (and with idmapd is the only way I know 
> for configuring nfsv4 for now), users that are not known at server side 
> are squashed to nobody / nogroup  (65534 / 65534).
> And a chown by root from the client fails if the user is not known at 
> server side.
> 
> That's a problem... now we need ldap everywhere...
> 
> We were often using NFS for exporting some diskspace to machines on an 
> as-needed basis,
> so this new behaviour complicates the things greatly for us :-/
> It's almost easier to setup iSCSI targets now :-((
> 
> Is there a way to have nfsv4 with the behaviour of users of nfsv3, that 
> is, using numeric IDs instead of the names, like: "nfsserver, don't care 
> if you don't know the user, just give me the numeric ID for the file..."

No. That is not allowed by the spec.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

