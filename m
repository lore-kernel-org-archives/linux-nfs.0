Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:7579 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab3CUBvP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 21:51:15 -0400
Date: Wed, 20 Mar 2013 21:41:40 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christopher T Vogan <cvogan@us.ibm.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, nfsv4 list <nfsv4@ietf.org>,
        Tom Haynes <Tom.Haynes@netapp.com>
Message-ID: <1533754809.4129999.1363830100661.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <1363826022.4790.89.camel@leira.trondhjem.org>
Subject: Re: [nfsv4] What is NFSv4 READDIR doesn't return a filehandle....
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2013-03-20 at 23:53 +0000, Haynes, Tom wrote:
> > Please note that I have cc'ed the NFSv4 list over at the IETF.
> >
> > On Mar 20, 2013, at 3:40 PM, Christopher T Vogan <cvogan@us.ibm.com>
> > wrote:
> >
> > > All,
> > >
> > > Sorry for this late posting, a coworker was made aware of this
> > > thread
> > > recently and
> > > has these replies to make. Our server implementation is the one
> > > being
> > > complained about in this thread.
> > >
> > >
> > > Quoted text is from various entries in this forum.
> > >
> > >
> > > Neil Brown:
> > > ===========
> > >> Just a thought: while coping with broken servers would not be a
> > >> good
> > > path to
> > >> follow, detecting protocol violations and reporting an error
> > >> might be...
> > >> should the NFS client treat a missing filehandle and a malformed
> > >> reply?
> > >
> > > The server is allowed to remove an attribute bit from an entry in
> > > the
> > > readdir
> > > reply, this is not "broken" nor is the reply "malformed". The lack
> > > of a
> > > filehandle in the reply is deterministic.
> > >
> > >
> > >
> > > Trond Myklebust:
> > > ================
> > >>> A customer has come across a server which does not return the
> > > filehandle
> > >>> information (is that allowed?).
> > >>
> > >> The filehandle attribute is a mandatory attribute according to
> > >> RFC3530,
> > > so I believe that the answer is "no".
> > >
> > > Mandatory is described in RFS 3530 as that the server must return
> > > the
> > > attribute
> > > on a GETATTR. (Section 5, page 36). There is nothing saying that
> > > it is
> > > mandatory to return on a READDIR. Our server will return the
> > > filehandle
> > > on a LOOKUP/GETATTR every time.
> >
> >
> >
> > GETATTR and READDIR both return attributes. To be precise, they
> > return
> > a fattr4.
> >
> > Looking at Section 15.26.4 (roughly pages 277-279 of the most recent
> > copy)
> > of 3530bis (3530 is on the way to being replaced), READDIR states:
> >
> >    The READDIR operation retrieves a variable number of entries from
> >    a
> >    filesystem directory and returns client requested attributes for
> >    each
> >    entry along with information to allow the client to request
> >    additional directory entries in a subsequent READDIR.
> > ...
> >    On successful return, the server's response will provide a list
> >    of
> >    directory entries. Each of these entries contains the name of the
> >    directory entry, a cookie value for that entry, and the
> >    associated
> >    attributes as requested. The "eof" flag has a value of TRUE if
> >    there
> >    are no more entries in the directory.
> >
> > Any client implementation has no way to request that any server
> > implementation
> > return the filehandle because the filehandle is not an attribute
> > which
> > can be requested. I.e., it is mandatory.
> >
> > If the intent was to allow the server to not return a filehandle for
> > READDIR but to
> > allow it to return one for GETATTR, then it would have been made
> > OPTIONAL.
> >
Well, I don't see any difference between a mandatory attribute and a
recommended attribute that the server claims to support via the
supported_attributes attribute.

I do believe that the server can choose not to return all of the
mandatory and supported recommended attributes in the readdir reply.
(If not, why have a bitmap of returned attributes?)

One example here is the mounted_on_fileid, which some servers choose
to only "support" for server mount points. (The FreeBSD server returns
this attribute for all file handles, setting it to the same value as
fileid for non-mount-points, but I am pretty sure some other servers
do not return mounted_on_fileid for non-mount-points.)

> > Whether or not the client used to work with such a server
> > implementation
> > or not is immaterial as far as standard compliance is concerned.
> >
> > If you like, we can clean up the corresponding language in 3530bis
> > to
> > explicitly state that REQUIRED attributes are indeed required
> > whether
> > in response to GETATTR or READDIR.
I assume that by REQUIRED you are referring to "mandatory attributes".

> 
> It might rather be useful to add language to point out that the
> "filehandle" attribute SHOULD NOT be used for the GETATTR case. We
> have
> GETFH, and AFAICR, all the language around referrals etc is written
> with
> the assumption that clients _won't_ use GETATTR to retrieve the
> filehandle.
> 
> Ditto for the case of "rdattr_error", which makes absolutely no sense
> whatsoever in a GETATTR request.
> 
And as I mentioned above, can a server choose to return mounted_on_fileid
for only some FHs when it claims to support the attribute? (I think that
is allowed and since I don't see a difference between mandatory and supported
recommended attributes I think the same applies to FH.)

Btw, when a server chooses to not return an FH in the readdir reply although
it was requested, the FreeBSD client "readdirplus" essentially falls back to
a basic "readdir" for the file name (ie. it doesn't prime the name and attribute
caches for it).

rick

> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
