Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp106.prem.mail.sp1.yahoo.com ([98.136.44.61]:31749 "HELO
	smtp106.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S937358Ab0CPCbf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 22:31:35 -0400
Message-ID: <4B9EED86.2060003@schaufler-ca.com>
Date: Mon, 15 Mar 2010 19:31:34 -0700
From: Casey Schaufler <casey@schaufler-ca.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Jamie Lokier <jamie@shareable.org>, Brad Boyer <flar@allandria.com>,
        James Morris <jmorris@namei.org>, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute protocol
 (XATTR)
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>	 <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org>	 <20100309035932.GA14237@cynthia.pants.nu> <4B95E167.40306@schaufler-ca.com>	 <20100309070444.GA18216@cynthia.pants.nu>	 <20100309193545.GE11042@shareable.org> <4B971611.8030801@schaufler-ca.com>	 <20100315031951.GU6491@shareable.org> <4B9DBAB0.5060500@schaufler-ca.com>	 <20100315142803.GC15133@shareable.org>  <4B9EC2B9.3030800@schaufler-ca.com> <1268696947.3155.6.camel@localhost.localdomain>
In-Reply-To: <1268696947.3155.6.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
> On Mon, 2010-03-15 at 16:28 -0700, Casey Schaufler wrote:
>
>   
>> You're missing something. Privilege semantics are different. The
>> behavior of unlinked files is different. Locking is different. You
>> are correct that in most cases it does not matter. We're not talking
>> about the common case, we're talking about using xattrs to store
>> information that is used to make security decisions. It is quite
>> difficult to make security claims when an object can be accessed
>> under two different sets of semantics.
>>     
>
> I'm sorry. Exactly _how_ are you going to prevent files from being
> accessed under more than one set of semantics under NFS? You have _no_
> idea what kind of security mechanisms are implemented on the client.
>
> All you can do is export a given set of security labels and hope...
>
>   

Not going to. That's not the point of the discussion, even though
you have a very valid point. The question was about how you might
deal with the differences between access on the NFS server and the
NFS client. I made a proposal that has performance implications,
and I acknowledge those implications. The proposal that I made
also assumes that the policy being enforced on the clients (one
of which is the server, NFS mounting the file system locally) is
sufficiently uniform to meet the needs of the site. I realize that
the probability that your average deployment could achieve this
state is painfully small. Security at the level where this is
useful remains quite rare but is taken very seriously in the cases
where it is useful. Without James' implementation the capability
to deploy something correctly does not exist. With the implementation
it only requires heroic and draconian effort. It's not convenient,
but it is possible.

And before someone starts arguing that no one would ever use
this, I will point out that this mechanism has been deployed
on Unix systems for many years. I realize that by itself the
fact that other systems do it is not a compelling argument.
I will point out the those who deploy such systems do so with
a level of discipline that would shock most software developers.
Generally there lives at stake. Sometimes it's just large
amounts of money. In any case these people can deal with a
performance issue and can ensure that all the systems they are
dealing with treat data the same way.

> Trond
>
>
>   

