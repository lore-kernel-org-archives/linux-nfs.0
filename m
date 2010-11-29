Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:20663 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358Ab0K2WKZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 17:10:25 -0500
From: <Daniel.Muntz@emc.com>
To: <Trond.Myklebust@netapp.com>, <spelic@shiftmail.org>
CC: <linux-nfs@vger.kernel.org>
Date: Mon, 29 Nov 2010 17:09:16 -0500
Subject: RE: NFSv4 behaviour on unknown users
Message-ID: <DE966DA98A4ABE438D726BDF1699CF610437B188C9@MX05A.corp.emc.com>
In-Reply-To: <1291054975.12784.17.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Looks like it's time for my annual numeric uid rant...

IMHO this was the silliest decision in the v4 spec, and a frequent hindrance to users wanting to move from v3.  Once again, I'm going to suggest that the v4.x series officially support numeric uid/gid strings as first-class user identifiers, rather than trying to force "name@domain" on systems that do not need this functionality, and are worse off for having to support it.  The fact that every OS needs different configuration to get it working just adds to the insanity.  Supply something that works (numeric id strings) as the default, but allow the name@domain "enhancement" for those who want it.  Then, everything just works, people seamlessly migrate to v4.x, and world peace is achieved.  There could even be an option to disable numeric id string support for those vehemently opposed to its existence, but at least in this case sysadmins have to go out of their way to make their system return nobody/nogroup for all users, rather than being the default behavior.

  -Dan

-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Trond Myklebust
Sent: Monday, November 29, 2010 10:23 AM
To: Spelic
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 behaviour on unknown users

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

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

