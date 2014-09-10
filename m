Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:54675 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbaIJAbB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 20:31:01 -0400
Received: by mail-ie0-f181.google.com with SMTP id lx4so157779iec.40
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 17:31:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1409855758.8703.48.camel@willson.usersys.redhat.com>
References: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com>
	<540831FE.1010208@rug.nl>
	<CALXu0Ufa166-PocKOOMBSF6yONaMxyUMHQmLA8NuSda9sE8PVQ@mail.gmail.com>
	<54085BF3.60802@rug.nl>
	<1409855758.8703.48.camel@willson.usersys.redhat.com>
Date: Wed, 10 Sep 2014 02:31:00 +0200
Message-ID: <CALXu0UeX=KRD949z8QX0-XoHQucP5X=0ERmTdMrSxSjQFJatsQ@mail.gmail.com>
Subject: Re: How to use NFS with multiple principals in different realms?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Simo Sorce <simo@redhat.com>
Cc: Jurjen Bokma <j.bokma@rug.nl>, "<kerberos@mit.edu>" <kerberos@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4 September 2014 20:35, Simo Sorce <simo@redhat.com> wrote:
> On Thu, 2014-09-04 at 14:32 +0200, Jurjen Bokma wrote:
>> On 09/04/2014 01:25 PM, Cedric Blancher wrote:
>> > On 4 September 2014 11:33, Jurjen Bokma <j.bokma@rug.nl> wrote:
>> >> You use cross realm authentication, so that your NFS client may obtain
>> >> tickets for servers that are not in its own realm.
>> >
>> > What if I cannot use cross realm authentication? For example if both
>> > realms do not like each other?
>> > What if I really have to kinit into multiple realms? Kerberos since
>> > 1.10 can do that and klist now has a new flag -A to list all entries
>> > if KRB5CCNAME points to a directory, e.g.
>> > KRB5CCNAME=DIR:/tmp/krbcc$UID/
>> >
>> > Ced
>> >
>> I tried that about a year ago, and failed to make it work.
>
> The problem is that the server can only have one set of credentials from
> the POV of the client, and that's: nfs@fqdn (a GSSAPI name), that gets
> converted into a principal of the form nfs/fqdn@REALM (where REALM is
> determined by a mapping of the form domain_name->REALM in the client
> usually).

Per Oracle support this is not quite correct: if you have multiple
tickets in a DIR: then the NFS client is either required to negotiate
with the server (RFC 3530) or try the credentials in order until one
works.

>> As far as I know, gssd always picks the same key to authenticate with. I
>
> When rpc.gssd (potentially interposed by gss-proxy) then uses GSSAPI to
> obtain a ticket for the server it will choose the credentials that match
> the same REALM in preference, even if you have multiple credentials.

But that can't be right if you have tickets originating from more than
one realm in a DIR:, can it?

>
> The client has no way to know that you want to use a different set of
> credentials, because it doesn't even know (IIRC) what you are trying to
> access on the server when this call is made.

Still it has to try all options, i.e. negotiate. This is what the
reference implementation for NFS (Solaris) does.

>
>> did offer a patch on this list a couple of weeks ago that uses a
>> krb5.conf appdefaults option to configure *which* key, but that one
>> still doesn't make it possible to pick a different key for different shares.
>
> It allows you to choose a different key for the *machine* principal, but
> does nothing for authenticating users using different credentials.
>
> Simo.
>
> --
> Simo Sorce * Red Hat, Inc * New York
>

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
