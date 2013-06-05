Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:35928 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756080Ab3FEOZe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jun 2013 10:25:34 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "E.G. Keizer" <E.G.Keizer@vu.nl>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential
 issue.
Date: Wed, 5 Jun 2013 14:25:32 +0000
Message-ID: <1370442331.21544.16.camel@leira.trondhjem.org>
References: <51AF459A.1040609@vu.nl>
In-Reply-To: <51AF459A.1040609@vu.nl>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-06-05 at 16:05 +0200, E.G. Keizer wrote:
> First I would like to wholeheartedly support Neil Brown's comment. We at the
> Vrije Universiteit in Amsterdam (NL) also have the situation where the Kerberos
> administrator does not hand out machine credentials. A lot of Linux users from
> the Faculty of Sciences depend on the functionality that lets them access
> the NFS file servers with only their user credentials.

They should still be able to do that, but in that case, the state
management will have to default to AUTH_SYS to set up the lease, which
means that someone else can spoof requests to cancel the lease or change
the callback channel parameters.

> Secondly I would like to make a remark on basing client id's on the system's kerberos principal's name.
> That same faculty, in the times it had its own IT department, used an identical keytab for
> all Linux workstations, using the principal names "[nfs|root|host]/workstation@FEW.VU.NL".
> I understand this would lead to severe problems when the client id (co_ownerid) is based
> solely in the systems root principal name.

How so? The only problem should be that any one of those machines can go
and cancel or change the lease of any other. That's a compromise that
you decided upon when you decided to use one keytab for all of them.

> It seems to me that the issues about the client id look like a bag of worms. I've seen that the
> newest standard `requires' integrity protection for client id exchanges. I doubt
> that that will help when the source code of the NFS client is known and
> the client id is guessable.

What is the attack and how would it compromise security on the clients
that you care about?

>  The wisest thing might be to offer different options
> and let the administrators pick the one they like best?

We have two options available to you: auth_sys or RPCSEC_GSS w/krb5i.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
