Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755670AbaIQPFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2014 11:05:37 -0400
Date: Wed, 17 Sep 2014 11:05:28 -0400
From: Simo Sorce <simo@redhat.com>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Steve Dickson <steved@redhat.com>, Jurjen Bokma <j.bokma@rug.nl>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kerberos <kerberos@mit.edu>
Subject: Re: How to use NFS with multiple principals in different realms?
Message-ID: <20140917110528.130aeb7b@willson.usersys.redhat.com>
In-Reply-To: <CALXu0UdQ9a4NTjhuXtRuCf6vmpC4B8CunMaH=NaQnUYLY=YAHw@mail.gmail.com>
References: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com>
	<540831FE.1010208@rug.nl>
	<CALXu0Ufa166-PocKOOMBSF6yONaMxyUMHQmLA8NuSda9sE8PVQ@mail.gmail.com>
	<54085BF3.60802@rug.nl>
	<1409855758.8703.48.camel@willson.usersys.redhat.com>
	<CALXu0UeX=KRD949z8QX0-XoHQucP5X=0ERmTdMrSxSjQFJatsQ@mail.gmail.com>
	<1933258307.20622714.1410354390763.JavaMail.zimbra@redhat.com>
	<CALXu0UdQ9a4NTjhuXtRuCf6vmpC4B8CunMaH=NaQnUYLY=YAHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Sep 2014 13:20:19 +0200
Cedric Blancher <cedric.blancher@gmail.com> wrote:

> What happens if there is no relation between KRB Realm names and
> FQDN/DNS? Can the NFS client find out which KRB Realm is used by the
> server?

Depending on the environment you may have 1 or 2 ways.

1. add domain to realm mapping in the appropriate section in krb5.conf
on the client.
2. allow the KDC to send back a referral (but not all clients will ask
their own KDC, some can do only 1).

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York
