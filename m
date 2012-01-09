Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45764 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933412Ab2AIWub convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 17:50:31 -0500
Message-ID: <1326149428.10779.10.camel@lade.trondhjem.org>
Subject: RE: [GIT PULL] Please pull NFS client bugfixes and cleanups
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Mon, 09 Jan 2012 17:50:28 -0500
In-Reply-To: <A4C37DBDA23D504B9F8F6ED1AD1F4F3245A40D11@SACMVEXC2-PRD.hq.netapp.com>
References: <1326142671.9041.1.camel@lade.trondhjem.org>
	 <201201092315.28230.wolfgang.walter@stwm.de>
	 <A4C37DBDA23D504B9F8F6ED1AD1F4F3245A40D11@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-01-09 at 14:28 -0800, Myklebust, Trond wrote: 
> > -----Original Message-----
> > From: Wolfgang Walter [mailto:wolfgang.walter@stwm.de]
> > Sent: Monday, January 09, 2012 5:15 PM
> > To: Myklebust, Trond
> > Cc: Linus Torvalds; linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org
> > Subject: Re: [GIT PULL] Please pull NFS client bugfixes and cleanups
> > 
> > On Monday 09 January 2012, Trond Myklebust wrote:
> > > Hi Linus,
> > >
> > > Please pull from the "nfs-for-3.3" branch of the repository at
> > >
> > >    git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
> > > nfs-
> > for-3.3
> > >
> > > This will update the following files through the appended changesets.
> > >
> > >   Cheers,
> > >     Trond
> > >
> > >
> > > commit 074b1d12fe2500d7d453902f9266e6674b30d84c
> > > Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > Date:   Mon Jan 9 13:46:26 2012 -0500
> > >
> > >     NFSv4: Change the default setting of the nfs4_disable_idmapping
> > parameter
> > >
> > >     Now that the use of numeric uids/gids is officially sanctioned in
> > >     RFC3530bis, it is time to change the default here to 'enabled'.
> > >
> > >     By doing so, we ensure that NFSv4 copies the behaviour of NFSv3
> > > when
> > we're
> > >     using the default AUTH_SYS authentication (i.e. when the client uses the
> > >     numeric uids/gids as authentication tokens), so that when new files are
> > >     created, they will appear to have the correct user/group.
> > >     It also fixes a number of backward compatibility issues when migrating
> > >     from NFSv3 to NFSv4 on a platform where the server uses different
> > uid/gid
> > >     mappings than the client.
> > >
> > >     Note also that this setting has been successfully tested against servers
> > >     that do not support numeric uids/gids at several
> > Connectathon/Bakeathon
> > >     events at this point, and the fall back to using string names/groups has
> > >     been shown to work well in all those test cases.
> > >
> > >     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > >
> > 
> > 
> > Does this mean that one has to modify all one's clients to get the old
> > behaviour?
> > 
> > I'm not sure if this is a really good idea. I don't see the advantage. This will
> > break a lot of existing installations when upgrading to >=3.3. And someone
> > migrating from NFSv3 to NFSv4 has to give some thoughts to it anyway.
> 
> Please read the changelog and documentation:
> 
> If your server doesn’t support numeric uids/gids, then you will see _no_ change in behaviour.
> 
> If your server does support numeric uids/gids, and has the same mapping between numeric uids/gids and username/groupname as your clients, then you will see _no_ change in behaviour.
> 
> If your server does support numeric uids/gids, but the mapping between numeric uids/gids and username/groupname differs between server and client (e.g.. uid=20 maps to different users on the client and server) then you already had a problem in that creating the file using NFSv4 would result in you seeing the wrong owner and/or group. If this case, and this case only, the change to nfs4_disable_idmapper will result in you now seeing the correct owner/group for these files (just as if you were using NFSv3).
> 
> IOW: the only people who will want to use the old setting are those with broken servers that return incorrect errors when confronted with a numeric uid/gid. We have found no evidence that any such servers exist during the last full year of testing.

Actually, let me amend that last statement.

The only broken server we found was the Linux server, which was
returning NFS4ERR_BADNAME in a situation where the protocol specified
that it should be returning NFS4ERR_BADOWNER. This is why we have the
little comment "The following works around a Linux server bug!" in the
client code.
Commit f6af99ec1b261e21219d5eba99e3af48fc6c32d4 (nfsd4: name->id mapping
should fail with BADOWNER not BADNAME) fixed that server bug exactly one
year ago, and the fix was subsequently pushed to stable@kernel.org...

IOW: unless you find something earth-shattering when you enable the
option in your existing clients (the option has existed since 2.6.39),
I'd prefer to change the default as soon as possible in order to fix the
existing brokenness for those people running NFSv4 without the benefit
of an ldap/nis/yp server to ensure a homogeneous uid/gid name space...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

