Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:4526 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755142Ab3CUDi4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 23:38:56 -0400
Date: Wed, 20 Mar 2013 23:38:54 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christopher T Vogan <cvogan@us.ibm.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Tom Haynes <Tom.Haynes@netapp.com>,
        nfsv4 list <nfsv4@ietf.org>
Message-ID: <829780013.4132912.1363837134236.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <1363831497.4790.114.camel@leira.trondhjem.org>
Subject: Re: [nfsv4] What is NFSv4 READDIR doesn't return a filehandle....
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2013-03-20 at 21:41 -0400, Rick Macklem wrote:
> > Trond Myklebust wrote:
> > > On Wed, 2013-03-20 at 23:53 +0000, Haynes, Tom wrote:
> > > > Please note that I have cc'ed the NFSv4 list over at the IETF.
> > > >
> > > > On Mar 20, 2013, at 3:40 PM, Christopher T Vogan
> > > > <cvogan@us.ibm.com>
> > > > wrote:
> > > >
> > > > > All,
> > > > >
> > > > > Sorry for this late posting, a coworker was made aware of this
> > > > > thread
> > > > > recently and
> > > > > has these replies to make. Our server implementation is the
> > > > > one
> > > > > being
> > > > > complained about in this thread.
> > > > >
> > > > >
> > > > > Quoted text is from various entries in this forum.
> > > > >
> > > > >
> > > > > Neil Brown:
> > > > > ===========
> > > > >> Just a thought: while coping with broken servers would not be
> > > > >> a
> > > > >> good
> > > > > path to
> > > > >> follow, detecting protocol violations and reporting an error
> > > > >> might be...
> > > > >> should the NFS client treat a missing filehandle and a
> > > > >> malformed
> > > > >> reply?
> > > > >
> > > > > The server is allowed to remove an attribute bit from an entry
> > > > > in
> > > > > the
> > > > > readdir
> > > > > reply, this is not "broken" nor is the reply "malformed". The
> > > > > lack
> > > > > of a
> > > > > filehandle in the reply is deterministic.
> > > > >
> > > > >
> > > > >
> > > > > Trond Myklebust:
> > > > > ================
> > > > >>> A customer has come across a server which does not return
> > > > >>> the
> > > > > filehandle
> > > > >>> information (is that allowed?).
> > > > >>
> > > > >> The filehandle attribute is a mandatory attribute according
> > > > >> to
> > > > >> RFC3530,
> > > > > so I believe that the answer is "no".
> > > > >
> > > > > Mandatory is described in RFS 3530 as that the server must
> > > > > return
> > > > > the
> > > > > attribute
> > > > > on a GETATTR. (Section 5, page 36). There is nothing saying
> > > > > that
> > > > > it is
> > > > > mandatory to return on a READDIR. Our server will return the
> > > > > filehandle
> > > > > on a LOOKUP/GETATTR every time.
> > > >
> > > >
> > > >
> > > > GETATTR and READDIR both return attributes. To be precise, they
> > > > return
> > > > a fattr4.
> > > >
> > > > Looking at Section 15.26.4 (roughly pages 277-279 of the most
> > > > recent
> > > > copy)
> > > > of 3530bis (3530 is on the way to being replaced), READDIR
> > > > states:
> > > >
> > > >    The READDIR operation retrieves a variable number of entries
> > > >    from
> > > >    a
> > > >    filesystem directory and returns client requested attributes
> > > >    for
> > > >    each
> > > >    entry along with information to allow the client to request
> > > >    additional directory entries in a subsequent READDIR.
> > > > ...
> > > >    On successful return, the server's response will provide a
> > > >    list
> > > >    of
> > > >    directory entries. Each of these entries contains the name of
> > > >    the
> > > >    directory entry, a cookie value for that entry, and the
> > > >    associated
> > > >    attributes as requested. The "eof" flag has a value of TRUE
> > > >    if
> > > >    there
> > > >    are no more entries in the directory.
> > > >
> > > > Any client implementation has no way to request that any server
> > > > implementation
> > > > return the filehandle because the filehandle is not an attribute
> > > > which
> > > > can be requested. I.e., it is mandatory.
> > > >
> > > > If the intent was to allow the server to not return a filehandle
> > > > for
> > > > READDIR but to
> > > > allow it to return one for GETATTR, then it would have been made
> > > > OPTIONAL.
> > > >
> > Well, I don't see any difference between a mandatory attribute and a
> > recommended attribute that the server claims to support via the
> > supported_attributes attribute.
> >
> > I do believe that the server can choose not to return all of the
> > mandatory and supported recommended attributes in the readdir reply.
> > (If not, why have a bitmap of returned attributes?)
> 
> That's for dealing with OPTIONAL attributes. Section 5.2 of RFC3530
> states:
> 
> "A client may ask for any of these attributes to be returned by
> setting
> a bit in the GETATTR request but must handle the case where the server
> does not return them."
> 
> Section 5.1 says:
> 
> "These MUST be supported by every NFS version 4 client and server in
> order to ensure a minimum level of interoperability." There are no
> exceptions made for READDIR.
> 
Yes, I just read them. I had forgotten (never realized) that for GETATTR
there is the rule that mandatory/required attributes must be returned.

You are also correct that there is no exception for READDIR. In fact,
I don't see any mention of READDIR in Sec. 5.1, 5.2. Both Sec. 5.1 and 5.2
refer specifically to GETATTR when stating whether they must be returned.

Then, when I read the description for READDIR, it seems to say that
the server is to set the rderror attribute if it cannot return all the
requested attributes (no exception for recommended/optional ones) or
fail the entire READDIR if the client hasn't asked for rderror.

Since this isn't what actually happens for mounted_on_fileid, I still
think the same should apply to other attributes requested by the
READDIR request and I don't see that the 5.1, 5.2 rule for GETATTR
applies to READDIR (ie. FH must be returned, but mounted_on_fileid
doesn't need to be).

> > One example here is the mounted_on_fileid, which some servers choose
> > to only "support" for server mount points. (The FreeBSD server
> > returns
> > this attribute for all file handles, setting it to the same value as
> > fileid for non-mount-points, but I am pretty sure some other servers
> > do not return mounted_on_fileid for non-mount-points.)
> >
> > > > Whether or not the client used to work with such a server
> > > > implementation
> > > > or not is immaterial as far as standard compliance is concerned.
> > > >
> > > > If you like, we can clean up the corresponding language in
> > > > 3530bis
> > > > to
> > > > explicitly state that REQUIRED attributes are indeed required
> > > > whether
> > > > in response to GETATTR or READDIR.
> > I assume that by REQUIRED you are referring to "mandatory
> > attributes".
> 
> I'm using the language from RFC5661 and RFC3530-bis, since that is the
> most up-to-date.
> 
I could nitpick and note that rfc3530bis is simply a draft at this point
in time and that RFC3530 is at this time the specification for NFSv4.0.
(The truth is I just haven't bothered reading rfc3530bis. Once it becomes
 an RFC and I get bit by changes, like the "uid # in the owner string"
 change, then I guess I'll have to.;-)

Btw, Sec. 5.1 also states that a client should be able to handle a
server that only supports the mandatory/required attributes.
Have you tested against a server that doesn't support the "fileid"
attribute yet? (I can guarantee that the FreeBSD client will
never work against such a server, so I don't have to worry about
trying to be fully conformant.;-)

rick

> > > It might rather be useful to add language to point out that the
> > > "filehandle" attribute SHOULD NOT be used for the GETATTR case. We
> > > have
> > > GETFH, and AFAICR, all the language around referrals etc is
> > > written
> > > with
> > > the assumption that clients _won't_ use GETATTR to retrieve the
> > > filehandle.
> > >
> > > Ditto for the case of "rdattr_error", which makes absolutely no
> > > sense
> > > whatsoever in a GETATTR request.
> > >
> > And as I mentioned above, can a server choose to return
> > mounted_on_fileid
> > for only some FHs when it claims to support the attribute? (I think
> > that
> > is allowed and since I don't see a difference between mandatory and
> > supported
> > recommended attributes I think the same applies to FH.)
> 
> The fileid and mounted_on_fileid are both OPTIONAL attributes, and as
> section 5.2 says, the client is required to be able to deal with the
> case where the server does not return them. As stated earlier, there
> is
> no such exception in 5.1.
> 
> > Btw, when a server chooses to not return an FH in the readdir reply
> > although
> > it was requested, the FreeBSD client "readdirplus" essentially falls
> > back to
> > a basic "readdir" for the file name (ie. it doesn't prime the name
> > and attribute
> > caches for it).
> 
> Implementations are only relevant here in as far as they limit the
> protocol changes that RFC3530bis can make. Given that there are
> clients
> out there that assume a strict interpretation of RFC3530, then it is
> too
> late to have RFC3530bis relax that interpretation.
> 
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
