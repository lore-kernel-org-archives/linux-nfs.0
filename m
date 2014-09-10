Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4-phx2.redhat.com ([209.132.183.25]:36795 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbaIJNGi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 09:06:38 -0400
Date: Wed, 10 Sep 2014 09:06:30 -0400 (EDT)
From: Simo Sorce <simo@redhat.com>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Simo Sorce <simo@redhat.com>, Jurjen Bokma <j.bokma@rug.nl>,
        kerberos <kerberos@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Message-ID: <1933258307.20622714.1410354390763.JavaMail.zimbra@redhat.com>
In-Reply-To: <CALXu0UeX=KRD949z8QX0-XoHQucP5X=0ERmTdMrSxSjQFJatsQ@mail.gmail.com>
References: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com> <540831FE.1010208@rug.nl> <CALXu0Ufa166-PocKOOMBSF6yONaMxyUMHQmLA8NuSda9sE8PVQ@mail.gmail.com> <54085BF3.60802@rug.nl> <1409855758.8703.48.camel@willson.usersys.redhat.com> <CALXu0UeX=KRD949z8QX0-XoHQucP5X=0ERmTdMrSxSjQFJatsQ@mail.gmail.com>
Subject: Re: How to use NFS with multiple principals in different realms?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Cedric Blancher" <cedric.blancher@gmail.com>
> To: "Simo Sorce" <simo@redhat.com>
> Cc: "Jurjen Bokma" <j.bokma@rug.nl>, "<kerberos@mit.edu>" <kerberos@mit.edu>, "Linux NFS Mailing List"
> <linux-nfs@vger.kernel.org>, "Steve Dickson" <steved@redhat.com>
> Sent: Tuesday, September 9, 2014 8:31:00 PM
> Subject: Re: How to use NFS with multiple principals in different realms?
> 
> On 4 September 2014 20:35, Simo Sorce <simo@redhat.com> wrote:
> > On Thu, 2014-09-04 at 14:32 +0200, Jurjen Bokma wrote:
> >> On 09/04/2014 01:25 PM, Cedric Blancher wrote:
> >> > On 4 September 2014 11:33, Jurjen Bokma <j.bokma@rug.nl> wrote:
> >> >> You use cross realm authentication, so that your NFS client may obtain
> >> >> tickets for servers that are not in its own realm.
> >> >
> >> > What if I cannot use cross realm authentication? For example if both
> >> > realms do not like each other?
> >> > What if I really have to kinit into multiple realms? Kerberos since
> >> > 1.10 can do that and klist now has a new flag -A to list all entries
> >> > if KRB5CCNAME points to a directory, e.g.
> >> > KRB5CCNAME=DIR:/tmp/krbcc$UID/
> >> >
> >> > Ced
> >> >
> >> I tried that about a year ago, and failed to make it work.
> >
> > The problem is that the server can only have one set of credentials from
> > the POV of the client, and that's: nfs@fqdn (a GSSAPI name), that gets
> > converted into a principal of the form nfs/fqdn@REALM (where REALM is
> > determined by a mapping of the form domain_name->REALM in the client
> > usually).
> 
> Per Oracle support this is not quite correct: if you have multiple
> tickets in a DIR: then the NFS client is either required to negotiate
> with the server (RFC 3530) or try the credentials in order until one
> works.

I have the impression you are confusing client and server credentials, what
section do you refer to exactly ?

> >> As far as I know, gssd always picks the same key to authenticate with. I
> >
> > When rpc.gssd (potentially interposed by gss-proxy) then uses GSSAPI to
> > obtain a ticket for the server it will choose the credentials that match
> > the same REALM in preference, even if you have multiple credentials.
> 
> But that can't be right if you have tickets originating from more than
> one realm in a DIR:, can it?

It doesn't matter what tickets you have, you can have only one fqdn->REALM
mapping (at least with current libraries), so the server REALM is determined
first, then the most appropriate set of credentials available to the client
is selected.
>From memory the order is:
1. matching Realm if any credential in that Realm is available
2. default Realm as defined in krb5.conf if credentials in that Realm are
   available, this will attempt to get a cross-realm TGT to the target
   Realm first
3. the first credential available in (1) and (2) do not match

> > The client has no way to know that you want to use a different set of
> > credentials, because it doesn't even know (IIRC) what you are trying to
> > access on the server when this call is made.
> 
> Still it has to try all options, i.e. negotiate. This is what the
> reference implementation for NFS (Solaris) does.

Not the Linux clients, afair.

Simo.
