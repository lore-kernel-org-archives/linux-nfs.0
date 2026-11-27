Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795797035;
	b=1suE0Yk4JbDyl0qNzKODdWDmoUjpHz1GPXEMRIWUNjPXB8gLJ3BqwFgSkvIO2erZWF4T
	 3YRv2k0nKf09JNK4KUxKNg8NeAxqLR+/85g61drAQCSOfwQTYeTEiSfOmBL/CJ71b4jcL
	 7SWYcTx7KXbYTBhPphZuU/8l2dxkmLjhyiAixuu+zRTtYa0iCOEhioQ3jgLdWUmvraEgI
	 1Gt7Ect0AAC19JRc977urx1Ua1c7fmssHBsJn3qhYHa1JimmB0UnpYMuNyXRB/5Gv5FRM
	 TZDjDQk8fHF5Jn4+WqOfaH7qGXnvZXV7uSaNWaJ0vSWhPM8sriXZHnQe9H9IRab970Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795797035;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=Sw0tp8NDejfGg7X2BMLM/bjCiaduIGwJmfTqzVWl61E=;
	b=a5GibqndlyEsS9I4bLhA/2AZeadenAzkfNQDqRNEp8vmJmqrcl2W2fHPwUTNOSAHQvEa
	 7avM/WVXO0b9MvT1kPdC1nIJ19aK6LMprGem6twUX3tIWEmY6vnWq21UvE7vH+YJnQbeX
	 pL5mp0E1qA4RqPBbatgoOU+fCaiiVaPCAerD88AH1dc1ZCuG55D+xzPFKjP8X94TdXXhS
	 j1BgKU29mb3IXnvaBkdcKU2p3tqCXtLjUUC3ESp5d4MtZGP2lKjehxcX9BmHYRmsZKSOV
	 LldFQz0rZKw+3JPqhP+bqrrwUkd+KioyHr/+qembMOWclJxi1aleHxJbW0BPiJbaS+A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mghHXH79;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 70629606A324;
	Fri, 27 Nov 2026 16:30:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mghHXH79
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A38701F0089A;
	Fri, 27 Nov 2026 16:30:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795797034;
	bh=Sw0tp8NDejfGg7X2BMLM/bjCiaduIGwJmfTqzVWl61E=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=mghHXH79DxJD14zUrWcTaPxXHAVc8vhsm5WZmqMEElaOgUzzkbap0YRw97Fns4Bc/
	 jsST1rGi1TC5p7nXNi1WvFcBcQgcutvExdcd1oL+lHRvReu74td4KlKcSY6RoSE1bL
	 jLpvQJPI4u2lgXvBwQIWHOYSaRs1q4YbP413XzWQ0JLYS/bEXvgzuQBrCL5znBiZgK
	 5Fx7gmQPTUG6chOlqNWEAFpsIQMGXKMmxST20xpwFVXZOIHLOOMYVpl7XUgfl6NLyW
	 lhrBr9HDyHPuyDja+KgUSq3Z5rIldITrqmk2mX0vU8z7ekXcHBDVlCwYHhnLYNiKW0
	 DFJgSHe/13O2Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id DA185F40066;
	Fri, 27 Nov 2026 11:30:32 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 27 Nov 2026 11:30:32 -0500
X-ME-Sender: <xms:KLAJayV9S1YvMsnQ1LGCav8NXCjBj8xgQUO-mq3w96-0FZObKiLfqA>
    <xme:KLAJa5ZaPuDYiDfQab55wJTxi8BRN1iXYAYyIdiCc9L01Dy5AA998zTdaEFbK1aGM
    bHaypsvFlmhba2b6dz1AXOuYFRXDko_Pgoiru_IikrCY_W43uEqz38x>
X-ME-Proxy-Cause: dmFkZTEQYo7d31CaQQDpLnR4G7vJ+9syIEHphpomb/uGssUZqpOqMQ32iGMPTc9KW/2l2Y
    Cq0tkdZOuWVuNsLi7DyAFvPT9nOE9wa3InXGuOuQBGaBQ8uDsWJ7tTmpVb/ZmKRyQLBSVr
    YUZ2EUX+JT5M+a9K2Crbgfu8YTE9Rqdx4gRQmu7T+ns9jBiLlRBY8eowZTFj+vTLal8kS0
    iX0vVv9kwO3P9cmi4quZ4AEwQo+nA//IEG/IJS6RX8Q3S2Bc/rtlwyACYY926bPR3Z4S7y
    okXqDJUQz+3H1cbeuVW0hdyz1wBhhK/DTHxWjT0BhiIqFRD3A4DkztJXW6OCmIeGcl/JJY
    f5Eopi/1cOm/+QXjeqX521u3ULZeRJogvbjX6U7W1ztFEf5AQipL6unWQQ+w8IV7LUxF9v
    1L2Ds8nn5XLfRUfiX+qm0qLICsq+d8JAlE8ZG3h3mEGiHEQDtOaXkhBPhPR/rCU2BK7L+D
    9h1yx8lSkAvWemetZCSRwMrMxz/IAB626OYRvD4V1jzZkp/V2ho9hOQgBdBJYu5hjT8yHe
    Ri5Ix+1RLMdK6oEPgSAkwH1ZXcKjZ9vMB4MQZA3VKTsSdDVQk5H7NLBtCt17ynumjr3xNM
    RaUbsrs2rev95OP9YY6/qG1K0dQ0PozayI0kmEerWOV0iKCShlOVI5T8WAOg
X-ME-Proxy: <xmx:KLAJa5Xt4J0cWCv85OOevdKrAVU9UeRpbR_f7bnnW_4sNhNyTjbsrQ>
    <xmx:KLAJa-f55YsBqF4Vl2sdxI9rxFXC_nxuIgCfTHoNoNYp19_k8P2xHA>
    <xmx:KLAJay8CkTrUINgwQD7M4L5nPVUg4kw0NpV9Nol46zQKFOgJweAJdg>
    <xmx:KLAJa-b3qgnDvJXrzGj17TcNhjdfVMcXCqV4yESED8_z0q0JcJCwgQ>
    <xmx:KLAJayuK1FDjqbq7shMocOFxoI_R41bbZVIy0OoUR-TaL_b-1rAT43bf>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A4EA1780070; Fri, 27 Nov 2026 11:30:32 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: A8Z6fJDuAPLk
Date: Fri, 27 Nov 2026 11:30:12 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Jakub Kicinski" <kuba@kernel.org>
Cc: "Donald Hunter" <donald.hunter@gmail.com>,
 "David S. Miller" <davem@davemloft.net>, "Paolo Abeni" <pabeni@redhat.com>,
 "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>,
 "Sabrina Dubroca" <sd@queasysnail.net>, "Keith Busch" <kbusch@kernel.org>,
 "Jens Axboe" <axboe@kernel.dk>, "Christoph Hellwig" <hch@lst.de>,
 "Sagi Grimberg" <sagi@grimberg.me>, "Chaitanya Kulkarni" <kch@nvidia.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Eric Dumazet" <edumazet@kernel.org>,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org,
 "Hannes Reinecke" <hare@kernel.org>
Message-Id: <bbac34f0-1f86-46e2-a3f1-248c65a1b9ec@app.fastmail.com>
In-Reply-To: <20261121161302.69f202c8@kernel.org>
References: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
 <20261121161302.69f202c8@kernel.org>
Subject: Re: [PATCH net-next v3 00/10] Deliver TLS session tags to upper-layer
 consumers (NFSD)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On Sat, Nov 21, 2026, at 7:13 PM, Jakub Kicinski wrote:
> On Fri, 13 Nov 2026 14:21:58 -0500 Chuck Lever wrote:
>> NFSD controls remote access to its exports today by IP address and
>> hostname. Neither of these are cryptographically secure. For
>> instance, a MitM can replace the response to a server's plaintext
>> DNS query. As a result, a malicious NFS client can pretend to be a
>> client whose hostname matches one that has access to exports it
>> would otherwise be denied access to.
>>=20
>> So instead, we want access-control decisions to be based on
>> cryptographically-vetted objects such as TLS peer-certificates.
>> In-kernel x.509 parsing would duplicate work mature userspace
>> libraries already do, so let's make tlshd evaluate peer certificates
>> in user space.
>>=20
>> The certificates are evaluated against admin-defined policy, such
>> as whether the certificate's Issuer matches a particular string.
>> tlshd then marks NFS TLS sessions with those policy matches. Admins
>> also provide a set of policy names on each NFSD export (allow_tags).
>> Computing the intersection with these per-export tags is quick and
>> completely separate from the details of parsing x.509 certificates.
>>=20
>> A yet-to-be-posted patch series introduces tag set support to the
>> exportfs command in nfs-utils. tlshd 1.5.0, current as of this
>> writing, already implements TLS session tagging.

> The patches look reasonable to me, overall. At a high level tho -=20
> I don't have any familiarity with "tag" based policies.
> Are you confident it's flexible and convenient enough to survive
> as uAPI?
>
> Naively I'd think it creates unnecessarily wide API on both ends
> (handshake and server). My knee jerk design would be to populate
> the full policy in the server, and only carry some "policy ID"
> thru the handshake. Number of policy IDs would equal to the number
> of tag combinations (which result in different behavior).
>
> Any examples of APIs like the one you're adding working well?

Here are a few similar mechanisms that are deployed and working.

1. OpenSSH certificate principals. A CA-signed certificate carries
   a set of principal names. AuthorizedPrincipalsFile lists the
   names a target accepts, and access is granted if any principal
   in the certificate matches a line. That is exactly the
   non-empty-intersection rule. AuthorizedPrincipalsCommand
   computes the set in user space, which is the role tlshd plays
   here. The difference is that principals are minted when the
   certificate is issued, not mapped by a local policy at handshake
   time. [3]

2. AWS IAM Roles Anywhere. It maps X.509 Subject/Issuer/SAN fields
   into session principal tags, such as aws:PrincipalTag/x509Subject/OU,
   through a per-profile attribute mapping. Resource and trust policies
   then condition on those tags. It even uses the name "session tags",
   and the certificate-to-tags step is configured separately from the
   resource policy, as in your design. The differences: AWS tags are
   key/value pairs, and the policy language is richer than set
   intersection. [1], [2]

3. Kerberos PAC group SIDs (AD, Samba, SMB). The KDC, a separate
   component, resolves identity into a set of group SIDs carried in
   the ticket. The file server grants access by intersecting that set
   with the resource ACL and never sees how membership was decided.
   Linux credentials already work this way: supplementary groups and
   the AUTH_SYS gid list are a set of IDs in the credential checked
   against the object. The kernel already enforces
   "set in the session =E2=88=A9 set on the resource".

The policy-ID model you mentioned looks a lot like labeled IPsec
(XFRMA_SEC_CTX). The IKE daemon puts a single security context on
the SA, and an LSM enforces it.

The kernel already does only mechanical enforcement (intersection).

Policy IDs make the problem bigger, not smaller, IMHO. One ID per
combination of tags that behaves differently, the combinations grow
combinatorially. Policy IDs also force one compiler that knows both
the certificate rules and every export, which joins together the two
independently managed configs that tags keep apart.

So, we could:

- Rename tags "group memberships" in the cover letter and documentation,
  since that is the term PAC, SSH and AWS deployments use.

- Pin the string format in the uAPI by specifying a character set,
  maximum length and the existing cap, with any other format rejected
  at the DONE downcall. Optionally, reserve a prefix: namespace so other
  upper-layer protocols (NVMe) can't collide with NFS tags.

- Clarify in the series cover letter that the kernel only intersects and
  group/tag policy is handled in user space.


Lastly, I haven't found a perfect fit for security policy reviewers, but
these come close:

  Cc: linux-security-module@vger.kernel.org
  Cc: Paul Moore <paul@paul-moore.com>


--=20
Chuck Lever

[1] IAM Roles Anywhere: certificate attribute mapping (https://docs.aws.=
amazon.com/rolesanywhere/latest/userguide/attribute-mapping.html)
[2] IAM Roles Anywhere: attribute mapping and trust policy
    (https://docs.aws.amazon.com/rolesanywhere/latest/userguide/attribut=
e-mapping-and-trust-policy.html)
[3] openssh-unix-dev: AuthorizedPrincipalsFile (2010) (https://lists.min=
drot.org/pipermail/openssh-unix-dev/2010-October/029012.html)
  - GitLab: AuthorizedPrincipalsCommand (https://docs.gitlab.com/adminis=
tration/operations/ssh_certificates/)
