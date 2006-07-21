From: "Yoder, Alan" <agy@netapp.com>
Subject: RE: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 21 Jul 2006 10:16:23 -0700
Message-ID: <992BA60650F1584BA63E339312CE420305B9456D@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>, "Pawlowski,
	Brian" <beepy@netapp.com>, Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfsv4-bounces@ietf.org>
To: "Noveck, Dave" <Dave.Noveck@netapp.com>,
	"Sam Falkner" <Sam.Falkner@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

A whisper of warning from experience in other
standards bodies (SNIA), where we have things
like this in our spec.  It's dangerous to
place informational algorithms in otherwise=20
normative text, even if they're labeled as=20
informational.  They tend to get enshrined in=20
plugfest procedures, independent certification=20
or test suites, and such, and then they're not=20
really informational any more.  Even the informal
"language" they're written in can get set up
on a pedestal.

I realize this may not be welcome advice, but I'd
advise either keeping these things out of the spec,
or doing the work to formalize them, verify them,=20
and make them normative.  Or both.

Alan

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Alan G. Yoder                                    agy@netapp.com
Technical Staff                          =20
Network Appliance, Inc.                            408-822-6919
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D






> -----Original Message-----
> From: Noveck, Dave=20
> Sent: Friday, July 21, 2006 8:10 AM
> To: Sam Falkner
> Cc: Lisa Week; nfsv4@ietf.org; J. Bruce Fields;=20
> nfs@lists.sourceforge.net; Spencer Shepler; Pawlowski, Brian;=20
> Andreas Gruenbacher
> Subject: RE: [nfsv4] Re: NFSv4 ACL and POSIX interaction /=20
> mask,draft-ietf-nfsv4-acls-00 not ready
>=20
> > The current ACL spec, in the minorversion1 draft and in the=20
> previous =20
> > ACL drafts, rigorously specifies mode/ACL interactions by=20
> specifying =20
> > algorithms.  Bruce had the comment that the spec read as=20
> though the =20
> > algorithm was mandatory.
>=20
> That was my reading.  Was that the intention or not?
>=20
> > Rethinking, it would be preferable to have the ACL specification =20
> > specify requirements, and have the algorithms serve as examples. =20
>=20
> I think the requirements that the algorithms are intended to address,
> would be helpful in understanding, whether the algorithms are=20
> examples or are mandatory.
>=20
> > Or, =20
> > rewrite the sections as requirements, and release=20
> algorithms outside =20
> > the minorversion1 draft, possibly through one or more=20
> informational =20
> > RFCs.  This would shorten the minorversion1 draft, without =20
> > invalidating the existing semantics.
>=20
> I think this would complicate understanding and review.  Even if
> the algorithms are examples and not mandatory, I would imagine
> they would be helpful in understanding the requirements and their
> implications, and if they are helpful, they should be in the spec,
> with an indication that they are illustrative and not mandatory.
>=20
> > We'll try to have an initial draft of the ACL parts of the =20
> > minorversion1 document on August 7.  I'll also add an issue=20
> to nfs4-=20
> > editor.org.
>=20
> Here's a couple of other things I've noted that you might consider
> while working in this area:
>=20
>     There is statement about not using additional mode bits beyond
>     the ones defined but there is a "MUST NOT" addressed to the world
>     in general.  I think the mandate should be for the=20
> server.  It MUST
>     NOT return other bits on GETATTR and MUST return NFS4ERR_INVAL if
>     other bits are set on SETATTR or CREATE/OPEN-create.  The=20
> client is
>     free to use whatever bits he wants.  He is not disobeying the
> protocol
>     but he will get NFS4ERR_INVAL.
>=20
>     I don't see the point of allowing multiple behaviors in=20
> the case in=20
>     which both MODE and ACL are set.  Rather than rell the=20
> client how to
>=20
>     deal with all possible server behaviors, consider mandating the
> order=20
>     in which a SETATTR/CREATE with both MODE and ACL will be processed
> by=20
>     the server.  I think that would make life simpler for everybody.
> The
>     server knows what order he should do these in and the=20
> client knows=20
>     which order the changes will be done in.=20
>=20
> -----Original Message-----
> From: Sam Falkner [mailto:Sam.Falkner@Sun.COM]
> Sent: Thursday, July 20, 2006 6:57 PM
> To: Noveck, Dave
> Cc: Lisa Week; nfsv4@ietf.org; J. Bruce Fields;
> nfs@lists.sourceforge.net; Spencer Shepler; Pawlowski, Brian; Andreas
> Gruenbacher
> Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
> draft-ietf-nfsv4-acls-00 not ready
>=20
>=20
> On Jul 18, 2006, at 7:48 PM, Noveck, Dave wrote:
>=20
> > It seems like this is what most users would want.  It=20
> doesn't seem to
> > match what is specified in section 3.16.6.3 of draft-03.  That says
> > the acl is modified when you change the mode.
>=20
> Right -- see below...
>=20
> > What does solaris do if you do a chmod specifying a numeric mode
> > whose value is the same as would be set by doing a chomod +s?  Does
> > that change the ACL?
>=20
> Sorry, I misunderstood your earlier question -- I was testing=20
> against =20
> POSIX-draft ACLs, and not NFSv4 ACLs.  In the case of NFSv4 ACLs (on =20
> ZFS), it does change the ACL, whether you use "+s" or "4xxx".  In my =20
> test, it added a mask ACE for the supplemental user I had added =20
> before, even though the mask didn't really mask anything in this case.
>=20
> As you pointed out, chmod doesn't necessarily have to modify the ACL =20
> to set the setuid bit in the mode, unless the mode requires changes =20
> to the ACL for POSIX conformance.  The mode might require changing =20
> the ACL more times than is obvious, but the ACL specification =20
> shouldn't require unnecessary changes to the ACL...
>=20
> Here's an idea.  It's not an original idea, it's one that Bruce =20
> proposed last April, and unfortunately his comments went unanswered =20
> (mea culpa).
>=20
> The current ACL spec, in the minorversion1 draft and in the previous =20
> ACL drafts, rigorously specifies mode/ACL interactions by specifying =20
> algorithms.  Bruce had the comment that the spec read as though the =20
> algorithm was mandatory.
>=20
> Rethinking, it would be preferable to have the ACL specification =20
> specify requirements, and have the algorithms serve as=20
> examples.  Or, =20
> rewrite the sections as requirements, and release algorithms outside =20
> the minorversion1 draft, possibly through one or more informational =20
> RFCs.  This would shorten the minorversion1 draft, without =20
> invalidating the existing semantics.
>=20
> We'll try to have an initial draft of the ACL parts of the =20
> minorversion1 document on August 7.  I'll also add an issue to nfs4-=20
> editor.org.
>=20
> - Sam
>=20
> (Read on if you're interested in implications.)
>=20
> This would make it possible to craft different algorithms that can =20
> still meet the ACL spec in minorversion1.  Take this example single-=20
> ACE ACL as a starting point:
>=20
> EVERYONE@:read_data/execute::ALLOW
>=20
> and a starting mode of 0555.
>=20
> given a setattr of mode 4555 and no ACL, the new mode MUST become =20
> 4555, and the resulting ACL could legally be any of the following:
>=20
> (current algorithm)
> EVERYONE@:::ALLOW
> OWNER@:write_data/append_data::DENY
> OWNER@:read_data/write_xattr/execute/write_attributes/write_acl/=20
> write_owner::ALLOW
> GROUP@:write_data/append_data::DENY
> GROUP@:read_data/execute::ALLOW
> EVERYONE@:write_data/append_data/write_xattr/write_attributes/=20
> write_acl/write_owner::DENY
> EVERYONE@:read_data/read_xattr/execute/read_attributes/read_acl/=20
> synchronize::ALLOW
>=20
> or
>=20
> (simple ALLOW-only-when-possible algorithm)
> OWNER@:read_data/execute::ALLOW
> GROUP@:read_data/execute::ALLOW
> EVERYONE@:read_data/execute::ALLOW
>=20
> or
>=20
> (unchanged -- this algorithm is smart enough to see that no change =20
> was necessary)
> EVERYONE@:read_data/execute::ALLOW
>=20
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www1.ietf.org/mailman/listinfo/nfsv4
>=20
>=20

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
