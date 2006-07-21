From: "Noveck, Dave" <Dave.Noveck@netapp.com>
Subject: RE: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 21 Jul 2006 11:10:04 -0400
Message-ID: <C98692FD98048C41885E0B0FACD9DFB8023DF6B9@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>, "Pawlowski,
	Brian" <beepy@netapp.com>, Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfsv4-bounces@ietf.org>
To: "Sam Falkner" <Sam.Falkner@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

> The current ACL spec, in the minorversion1 draft and in the previous =20
> ACL drafts, rigorously specifies mode/ACL interactions by specifying =20
> algorithms.  Bruce had the comment that the spec read as though the =20
> algorithm was mandatory.

That was my reading.  Was that the intention or not?

> Rethinking, it would be preferable to have the ACL specification =20
> specify requirements, and have the algorithms serve as examples. =20

I think the requirements that the algorithms are intended to address,
would be helpful in understanding, whether the algorithms are=20
examples or are mandatory.

> Or, =20
> rewrite the sections as requirements, and release algorithms outside =20
> the minorversion1 draft, possibly through one or more informational =20
> RFCs.  This would shorten the minorversion1 draft, without =20
> invalidating the existing semantics.

I think this would complicate understanding and review.  Even if
the algorithms are examples and not mandatory, I would imagine
they would be helpful in understanding the requirements and their
implications, and if they are helpful, they should be in the spec,
with an indication that they are illustrative and not mandatory.

> We'll try to have an initial draft of the ACL parts of the =20
> minorversion1 document on August 7.  I'll also add an issue to nfs4-=20
> editor.org.

Here's a couple of other things I've noted that you might consider
while working in this area:

    There is statement about not using additional mode bits beyond
    the ones defined but there is a "MUST NOT" addressed to the world
    in general.  I think the mandate should be for the server.  It MUST
    NOT return other bits on GETATTR and MUST return NFS4ERR_INVAL if
    other bits are set on SETATTR or CREATE/OPEN-create.  The client is
    free to use whatever bits he wants.  He is not disobeying the
protocol
    but he will get NFS4ERR_INVAL.

    I don't see the point of allowing multiple behaviors in the case in=20
    which both MODE and ACL are set.  Rather than rell the client how to

    deal with all possible server behaviors, consider mandating the
order=20
    in which a SETATTR/CREATE with both MODE and ACL will be processed
by=20
    the server.  I think that would make life simpler for everybody.
The
    server knows what order he should do these in and the client knows=20
    which order the changes will be done in.=20

-----Original Message-----
From: Sam Falkner [mailto:Sam.Falkner@Sun.COM]
Sent: Thursday, July 20, 2006 6:57 PM
To: Noveck, Dave
Cc: Lisa Week; nfsv4@ietf.org; J. Bruce Fields;
nfs@lists.sourceforge.net; Spencer Shepler; Pawlowski, Brian; Andreas
Gruenbacher
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
draft-ietf-nfsv4-acls-00 not ready


On Jul 18, 2006, at 7:48 PM, Noveck, Dave wrote:

> It seems like this is what most users would want.  It doesn't seem to
> match what is specified in section 3.16.6.3 of draft-03.  That says
> the acl is modified when you change the mode.

Right -- see below...

> What does solaris do if you do a chmod specifying a numeric mode
> whose value is the same as would be set by doing a chomod +s?  Does
> that change the ACL?

Sorry, I misunderstood your earlier question -- I was testing against =20
POSIX-draft ACLs, and not NFSv4 ACLs.  In the case of NFSv4 ACLs (on =20
ZFS), it does change the ACL, whether you use "+s" or "4xxx".  In my =20
test, it added a mask ACE for the supplemental user I had added =20
before, even though the mask didn't really mask anything in this case.

As you pointed out, chmod doesn't necessarily have to modify the ACL =20
to set the setuid bit in the mode, unless the mode requires changes =20
to the ACL for POSIX conformance.  The mode might require changing =20
the ACL more times than is obvious, but the ACL specification =20
shouldn't require unnecessary changes to the ACL...

Here's an idea.  It's not an original idea, it's one that Bruce =20
proposed last April, and unfortunately his comments went unanswered =20
(mea culpa).

The current ACL spec, in the minorversion1 draft and in the previous =20
ACL drafts, rigorously specifies mode/ACL interactions by specifying =20
algorithms.  Bruce had the comment that the spec read as though the =20
algorithm was mandatory.

Rethinking, it would be preferable to have the ACL specification =20
specify requirements, and have the algorithms serve as examples.  Or, =20
rewrite the sections as requirements, and release algorithms outside =20
the minorversion1 draft, possibly through one or more informational =20
RFCs.  This would shorten the minorversion1 draft, without =20
invalidating the existing semantics.

We'll try to have an initial draft of the ACL parts of the =20
minorversion1 document on August 7.  I'll also add an issue to nfs4-=20
editor.org.

- Sam

(Read on if you're interested in implications.)

This would make it possible to craft different algorithms that can =20
still meet the ACL spec in minorversion1.  Take this example single-=20
ACE ACL as a starting point:

EVERYONE@:read_data/execute::ALLOW

and a starting mode of 0555.

given a setattr of mode 4555 and no ACL, the new mode MUST become =20
4555, and the resulting ACL could legally be any of the following:

(current algorithm)
EVERYONE@:::ALLOW
OWNER@:write_data/append_data::DENY
OWNER@:read_data/write_xattr/execute/write_attributes/write_acl/=20
write_owner::ALLOW
GROUP@:write_data/append_data::DENY
GROUP@:read_data/execute::ALLOW
EVERYONE@:write_data/append_data/write_xattr/write_attributes/=20
write_acl/write_owner::DENY
EVERYONE@:read_data/read_xattr/execute/read_attributes/read_acl/=20
synchronize::ALLOW

or

(simple ALLOW-only-when-possible algorithm)
OWNER@:read_data/execute::ALLOW
GROUP@:read_data/execute::ALLOW
EVERYONE@:read_data/execute::ALLOW

or

(unchanged -- this algorithm is smart enough to see that no change =20
was necessary)
EVERYONE@:read_data/execute::ALLOW

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
