Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbaIDSgK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2014 14:36:10 -0400
Message-ID: <1409855758.8703.48.camel@willson.usersys.redhat.com>
Subject: Re: How to use NFS with multiple principals in different realms?
From: Simo Sorce <simo@redhat.com>
To: Jurjen Bokma <j.bokma@rug.nl>
Cc: Cedric Blancher <cedric.blancher@gmail.com>,
        "<kerberos@mit.edu>" <kerberos@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Date: Thu, 04 Sep 2014 14:35:58 -0400
In-Reply-To: <54085BF3.60802@rug.nl>
References: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com>
		<540831FE.1010208@rug.nl>
	 <CALXu0Ufa166-PocKOOMBSF6yONaMxyUMHQmLA8NuSda9sE8PVQ@mail.gmail.com>
	 <54085BF3.60802@rug.nl>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-09-04 at 14:32 +0200, Jurjen Bokma wrote:
> On 09/04/2014 01:25 PM, Cedric Blancher wrote:
> > On 4 September 2014 11:33, Jurjen Bokma <j.bokma@rug.nl> wrote:
> >> You use cross realm authentication, so that your NFS client may obtain
> >> tickets for servers that are not in its own realm.
> > 
> > What if I cannot use cross realm authentication? For example if both
> > realms do not like each other?
> > What if I really have to kinit into multiple realms? Kerberos since
> > 1.10 can do that and klist now has a new flag -A to list all entries
> > if KRB5CCNAME points to a directory, e.g.
> > KRB5CCNAME=DIR:/tmp/krbcc$UID/
> > 
> > Ced
> > 
> I tried that about a year ago, and failed to make it work.

The problem is that the server can only have one set of credentials from
the POV of the client, and that's: nfs@fqdn (a GSSAPI name), that gets
converted into a principal of the form nfs/fqdn@REALM (where REALM is
determined by a mapping of the form domain_name->REALM in the client
usually).

> As far as I know, gssd always picks the same key to authenticate with. I

When rpc.gssd (potentially interposed by gss-proxy) then uses GSSAPI to
obtain a ticket for the server it will choose the credentials that match
the same REALM in preference, even if you have multiple credentials.

The client has no way to know that you want to use a different set of
credentials, because it doesn't even know (IIRC) what you are trying to
access on the server when this call is made.

> did offer a patch on this list a couple of weeks ago that uses a
> krb5.conf appdefaults option to configure *which* key, but that one
> still doesn't make it possible to pick a different key for different shares.

It allows you to choose a different key for the *machine* principal, but
does nothing for authenticating users using different credentials.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

