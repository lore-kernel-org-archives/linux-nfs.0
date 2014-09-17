Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:48146 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068AbaIQUaa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2014 16:30:30 -0400
Received: by mail-ig0-f172.google.com with SMTP id a13so258674igq.5
        for <linux-nfs@vger.kernel.org>; Wed, 17 Sep 2014 13:30:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140917110528.130aeb7b@willson.usersys.redhat.com>
References: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com>
	<540831FE.1010208@rug.nl>
	<CALXu0Ufa166-PocKOOMBSF6yONaMxyUMHQmLA8NuSda9sE8PVQ@mail.gmail.com>
	<54085BF3.60802@rug.nl>
	<1409855758.8703.48.camel@willson.usersys.redhat.com>
	<CALXu0UeX=KRD949z8QX0-XoHQucP5X=0ERmTdMrSxSjQFJatsQ@mail.gmail.com>
	<1933258307.20622714.1410354390763.JavaMail.zimbra@redhat.com>
	<CALXu0UdQ9a4NTjhuXtRuCf6vmpC4B8CunMaH=NaQnUYLY=YAHw@mail.gmail.com>
	<20140917110528.130aeb7b@willson.usersys.redhat.com>
Date: Wed, 17 Sep 2014 22:30:29 +0200
Message-ID: <CALXu0UcQ9YGTLnrjs5+AmVstAWmZ1QcNqOVeYyE-b_ktbfqvjw@mail.gmail.com>
Subject: Re: How to use NFS with multiple principals in different realms?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Simo Sorce <simo@redhat.com>
Cc: Steve Dickson <steved@redhat.com>, Jurjen Bokma <j.bokma@rug.nl>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kerberos <kerberos@mit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17 September 2014 17:05, Simo Sorce <simo@redhat.com> wrote:
> On Wed, 17 Sep 2014 13:20:19 +0200
> Cedric Blancher <cedric.blancher@gmail.com> wrote:
>
>> What happens if there is no relation between KRB Realm names and
>> FQDN/DNS? Can the NFS client find out which KRB Realm is used by the
>> server?
>
> Depending on the environment you may have 1 or 2 ways.
>
> 1. add domain to realm mapping in the appropriate section in krb5.conf
> on the client.
> 2. allow the KDC to send back a referral (but not all clients will ask
> their own KDC, some can do only 1).

But how can 1. help? Sure I can have my own krb5.conf but AFAIK
rpc.gssd only looks at he system /etc/krb5.conf and not at any custom
user defined location. Basically mount(8) would have to pass the
location of the custom krb5.conf file to rpc.gssd to facilitate the
mount, right?

I *think* we have a bigger problem here: Kerberos5 support in NFS
appears to be designed around the philosophy of one realm per machine
(one-to-rule-them'-all) and not that a single user or machine has
mounts from many different realms, right?

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
