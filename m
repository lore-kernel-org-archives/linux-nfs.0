Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57997 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759Ab0HQTXq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 15:23:46 -0400
Date: Tue, 17 Aug 2010 15:21:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <tdh@excfb.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        Neil Brown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Jim Rees <rees@umich.edu>, Daniel.Muntz@emc.com,
        linux-nfs@vger.kernel.org, nfsv4@ietf.org,
        Victor =?utf-8?Q?Matar=C3=A9?= <dreck@vmsd.ath.cx>
Subject: Re: numeric UIDs
Message-ID: <20100817192132.GC26609@fieldses.org>
References: <1280887336.24669.23.camel@heimdal.trondhjem.org>
 <20100805153421.GD27141@fieldses.org>
 <20100812092232.344314b2@notabene>
 <4C6559FA.5070809@RedHat.com>
 <20100813163156.GA16863@fieldses.org>
 <1CE074A1-2371-40E5-B0E5-F80474B02FA2@oracle.com>
 <4C6ACAE1.6060100@excfb.com>
 <20100817181842.GD23176@fieldses.org>
 <4C6AD861.4010506@excfb.com>
 <20100817184910.GB26609@fieldses.org>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20100817184910.GB26609@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Tom Haynes said:
> > While various ways pop to mind to hack this up, why not bring it up
> > to the working group and get consensus? Perhaps whomever struck down
> > Jim Rees will recall why it is such a bad idea and convince us all
> > to stay away from it. Or perhaps after years of enduring customers
> > who can't do the above, they will capitulate.

Adding nfsv4 list to the cc.

So, to summarize: every now and then somebody asks why the Linux NFSv4
implementation doesn't allow (ascii-encoded) numerical uid's and gid's;
most recently:

> On Tue, Aug 03, 2010 at 04:01:32AM +0200, Victor Mataré wrote:
>> I still hope I'm mistaken in assuming I have to go back to NFSv3 if I
>> want to skip NFSv4 UID mapping altogether and just use the numeric
>> UIDs the way they're stored on-disk....

They went on to describe a situation (apparently hypothetical) where NFS
is used to perform backups of a filesystem when the server storing the
backup (and maybe even the client performing the backup) lack mappings
referred to by the filesystem.

This is a use case that would work over v3 but likely not v4, as v4
implementors are advised against allowing this on page 47 of rfc 3530:

> >   To avoid this mechanism being used to subvert user and
> >   group translation, so that a client might pass all of the owners and
> >   groups in numeric form, a server SHOULD return an NFS4ERR_BADOWNER
> >   error when there is a valid translation for the user or owner
> >   designated in this way.  In that case, the client must use the
> >   appropriate name@domain string and not the special form for
> >   compatibility.

String uid's have advantages, but I've been arguing that:

> > >In the case of a user upgrading from NFSv3 to NFSv4, that's the behavior
> > >they've always had, so presumably they can live with it.  I'd prefer to
> > >avoid situations where something that previously worked over v3 fails
> > >when you upgrade the protocol version.
> > >
> > >I assume that most users arrive at NFSv4 by an upgrade from a previous
> > >version of NFS.
> > >
> > >So my priorities would be 1) to ensure the NFSv3->NFSv4 upgrade goes
> > >smoothly, then 2) to make it easy for users to switch from ids to
> > >strings, rather than forcing both at once.

So the question is whether there's still consensus for that SHOULD.

As Tom says:
> > I'd say that problem breaks down to being able to correctly
> > configure your id domain or to allowing a server which is not
> > connected to NIS/LDAP to be able to accept random users.  With
> > NFSv3, a server will happily serve up data in these situations.

So I suppose it comes down in part to a question of whether users of the
various implementations have actually seen these problems in practice
and, if so, whether diagnosing the problem, and setting up the required
mapping, has been an obstacle to NFSv4 adoption.

--b.
