Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:51158 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755992Ab3FEPUp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jun 2013 11:20:45 -0400
MIME-Version: 1.0
Message-ID: <5BC37A4B-83A9-462F-B625-0CCA10BD38EA@oracle.com>
Date: Wed, 5 Jun 2013 08:19:03 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
To: "E.G. Keizer" <E.G.Keizer@vu.nl>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential
 issue.
References: <51AF459A.1040609@vu.nl>
 <1370442331.21544.16.camel@leira.trondhjem.org> <51AF4FCB.9000503@vu.nl>
In-Reply-To: <51AF4FCB.9000503@vu.nl>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 5, 2013, at 10:48 AM, "E.G. Keizer" <E.G.Keizer@vu.nl> wrote:

> 
> 
> On 05/06/2013 16:25, Myklebust, Trond wrote:
>> On Wed, 2013-06-05 at 16:05 +0200, E.G. Keizer wrote:
>>> First I would like to wholeheartedly support Neil Brown's comment. We at the
>>> Vrije Universiteit in Amsterdam (NL) also have the situation where the Kerberos
>>> administrator does not hand out machine credentials. A lot of Linux users from
>>> the Faculty of Sciences depend on the functionality that lets them access
>>> the NFS file servers with only their user credentials.
>> 
>> They should still be able to do that, but in that case, the state
>> management will have to default to AUTH_SYS to set up the lease, which
>> means that someone else can spoof requests to cancel the lease or change
>> the callback channel parameters.
> We would probably accept that. But can you enlighten me as to why AUTH_SYS is better
> then krb5 (no i, no p)?

It isn't "better."  But if no GSS credential is available on the client, then AUTH_SYS is about the only choice for a client to use.

> 
>> 
>>> Secondly I would like to make a remark on basing client id's on the system's kerberos principal's name.
>>> That same faculty, in the times it had its own IT department, used an identical keytab for
>>> all Linux workstations, using the principal names "[nfs|root|host]/workstation@FEW.VU.NL".
>>> I understand this would lead to severe problems when the client id (co_ownerid) is based
>>> solely in the systems root principal name.
>> 
>> How so? The only problem should be that any one of those machines can go
>> and cancel or change the lease of any other. That's a compromise that
>> you decided upon when you decided to use one keytab for all of them.
> Mmm, not at the time we made the decision. But I just mentioned that as an example
> of the problems one can meet when deciding on the implementation of client id.
> The same problem, but on a smaller scale, occurs when the client id is based
> on the system principal and two or more systems use the same user principal as system
> principal.
>> 
>>> It seems to me that the issues about the client id look like a bag of worms. I've seen that the
>>> newest standard `requires' integrity protection for client id exchanges. I doubt
>>> that that will help when the source code of the NFS client is known and
>>> the client id is guessable.
>> 
>> What is the attack and how would it compromise security on the clients
>> that you care about?
> I am personally not that worried about this issue on our environment. But others seem to
> be in their environment. Otherwise the integrity requirement would not have ended up in
> the NFSv4 RFC. As fas as I understand the danger with a man-in-the-middle attack is that the attacker
> can see my client id and thus cancel my lease. When the man-in-the-middle can guess my
> client id he can still invalidate my lease even when i'am using krb5i.

No, SETCLIENTID would have to be authenticated with a Kerberos principal.  That's what protects the lease.

>> 
>>> The wisest thing might be to offer different options
>>> and let the administrators pick the one they like best?
>> 
>> We have two options available to you: auth_sys or RPCSEC_GSS w/krb5i.
> I meant different options for choosing the client id.

Have you seen the nfs4_unique_id boot parameter?  (cf. Documentation/filesystems/nfs.txt)  Pick a different UUID for each of your clients, and specify that UUID via the kernel command line.

You probably need to use the "migration" mount option as well.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




