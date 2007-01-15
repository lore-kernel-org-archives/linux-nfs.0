From: "Noveck, Dave" <Dave.Noveck@netapp.com>
Subject: RE: RE: Finding hardlinks
Date: Mon, 15 Jan 2007 07:53:37 -0500
Message-ID: <C98692FD98048C41885E0B0FACD9DFB8023DF95A@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: Spencer Shepler <spencer.shepler@sun.com>, nfs@lists.sourceforge.net,
	nfsv4@ietf.org
Return-path: <nfsv4-bounces@ietf.org>
To: "Benny Halevy" <bhalevy@panasas.com>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

I'm not going to be at Connectathon, but I could call in for a
discussion.=20

-----Original Message-----
From: Benny Halevy [mailto:bhalevy@panasas.com]=20
Sent: Monday, January 15, 2007 3:45 AM
To: Noveck, Dave; Trond Myklebust
Cc: Spencer Shepler; nfsv4@ietf.org; nfs@lists.sourceforge.net
Subject: Re: [nfsv4] RE: Finding hardlinks

How about discussing this topic in the upcoming Connectathon?

Benny

Noveck, Dave wrote:
> For now, I'm not going to address the controversial issues here,=20
> mainly because I haven't decided how I feel about them yet.
>=20
>      Whether allowing multiple filehandles per object is a good
>      or even reasonably acceptable idea.
>=20
>      What the fact that RFC3530 talks about implies about what
>      clients should do about the issue.
>=20
> One thing that I hope is not controversial is that the v4.1 spec=20
> should either get rid of this or make it clear and implementable.
> I expect plenty of controversy about which of those to choose, but=20
> hope that there isn't any about the proposition that we have to choose

> one of those two.
>=20
>> SECINFO information is, for instance, given out on a per-filehandle=20
>> basis, does that mean that the server will
> have
>> different security policies?=20
>=20
> Well yes, RFC3530 does say "The new SECINFO operation will allow the=20
> client to determine, on a per filehandle basis", but I think that just

> has to be considered as an error rather than indicating that if you=20
> have two different filehandles for the same object, they can have=20
> different security policies.  SECINFO in RFC3530 takes a directory fh=20
> and a name, so if there are multiple filehandles for the object with=20
> that name, there is no way for SECINFO to associate different policies

> with different filehandles.  All it has is the name to go by.  I think

> this should be corrected to "on a per-object basis" in the new spec no

> matter what we do on other issues.
>=20
> I think the principle here has to be that if we do allow multiple fh's

> to map to the same object, we require that they designate the same=20
> object, and thus it is not allowed for the server to act as if you=20
> have multiple different object with different characteristics.
>=20
> Similarly as to:
>=20
>> In some places, people haven't even started to think about the=20
>> consequences:
>>
>>     If GETATTR directed to the two filehandles does not return the
>>     fileid attribute for both of the handles, then it cannot be
>>     determined whether the two objects are the same.  Therefore,
>>     operations which depend on that knowledge (e.g., client side data
>>     caching) cannot be done reliably.
>=20
> I think they (and maybe "they" includes me, I haven't checked the=20
> history
> here) started to think about them, but went in a bad direction.
>=20
> The implication here that you can have a different set of attributes=20
> supported for the same object based on which filehandle is used to=20
> access the attributes is totally bogus.
>=20
> The definition of supp_attr says "The bit vector which would retrieve=20
> all mandatory and recommended attributes that are supported for this=20
> object.  The scope of this attribute applies to all objects with a=20
> matching fsid."  So having the same object have different attributes=20
> supported based on the filehandle used or even two objects in the same

> fs having different attributes supported, in particular having fileid=20
> supported for one and not the other just isn't valid.
>=20
>> The fact is that RFC3530 contains masses of rope with which to allow=20
>> server and client vendors to hang themselves.
>=20
> If that means simply making poor choices, then OK.  But if there are=20
> other cases where you feel that the specification of a feature is=20
> simply
>=20
> incoherent and the consequences not really thought out, then I think=20
> we need to discuss them and not propagate that state of affairs to
v4.1.
>=20
> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Friday, January 05, 2007 5:29 AM
> To: Benny Halevy
> Cc: Jan Harkes; Miklos Szeredi; nfsv4@ietf.org;=20
> linux-kernel@vger.kernel.org; Mikulas Patocka;=20
> linux-fsdevel@vger.kernel.org; Jeff Layton; Arjan van de Ven
> Subject: Re: [nfsv4] RE: Finding hardlinks
>=20
>=20
> On Fri, 2007-01-05 at 10:28 +0200, Benny Halevy wrote:
>> Trond Myklebust wrote:
>>> Exactly where do you see us violating the close-to-open cache=20
>>> consistency guarantees?
>>>
>> I haven't seen that. What I did see is cache inconsistency when
> opening
>> the same file with different file descriptors when the filehandle
> changes.
>> My testing shows that at least fsync and close fail with EIO when the
> filehandle
>> changed while there was dirty data in the cache and that's good.
> Still,
>> not sharing the cache while the file is opened (even on a different
> file
>> descriptors by the same process) seems impractical.
>=20
> Tough. I'm not going to commit to adding support for multiple=20
> filehandles. The fact is that RFC3530 contains masses of rope with=20
> which to allow server and client vendors to hang themselves. The fact=20
> that the protocol claims support for servers that use multiple=20
> filehandles per inode does not mean it is necessarily a good idea. It=20
> adds unnecessary code complexity, it screws with server scalability=20
> (extra GETATTR calls just in order to probe existing filehandles), and

> it is insufficiently well documented in the RFC: SECINFO information=20
> is, for instance, given out on a per-filehandle basis, does that mean=20
> that the server will have different security policies? In some places,

> people haven't even started to think about the consequences:
>=20
>       If GETATTR directed to the two filehandles does not return the
>       fileid attribute for both of the handles, then it cannot be
>       determined whether the two objects are the same.  Therefore,
>       operations which depend on that knowledge (e.g., client side
data
>       caching) cannot be done reliably.
>=20
> This implies the combination is legal, but offers no indication as to=20
> how you would match OPEN/CLOSE requests via different paths. AFAICS=20
> you would have to do non-cached I/O with no share modes (i.e.=20
> NFSv3-style "special" stateids). There is no way in hell we will ever=20
> support non-cached I/O in NFS other than the special case of O_DIRECT.
>=20
>=20
> ...and no, I'm certainly not interested in "fixing" the RFC on this=20
> point in any way other than getting this crap dropped from the spec. I

> see no use for it at all.
>=20
> Trond
>=20
>=20
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www1.ietf.org/mailman/listinfo/nfsv4

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
