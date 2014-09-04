Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp20.rug.nl ([129.125.60.101]:57168 "EHLO smtp20.rug.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185AbaIDMc4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2014 08:32:56 -0400
Received: from mail-wi0-f177.google.com ([172.23.16.207])
	by smtp20.rug.nl (8.14.7/8.14.7) with ESMTP id s84CWrN9005909
	for <linux-nfs@vger.kernel.org>; Thu, 4 Sep 2014 14:32:53 +0200
Received: by mail-wi0-f177.google.com with SMTP id cc10so980252wib.16
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:32:53 -0700 (PDT)
Message-ID: <54085BF3.60802@rug.nl>
Date: Thu, 04 Sep 2014 14:32:51 +0200
From: Jurjen Bokma <j.bokma@rug.nl>
MIME-Version: 1.0
To: Cedric Blancher <cedric.blancher@gmail.com>
CC: "<kerberos@mit.edu>" <kerberos@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: How to use NFS with multiple principals in different realms?
References: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com>	<540831FE.1010208@rug.nl> <CALXu0Ufa166-PocKOOMBSF6yONaMxyUMHQmLA8NuSda9sE8PVQ@mail.gmail.com>
In-Reply-To: <CALXu0Ufa166-PocKOOMBSF6yONaMxyUMHQmLA8NuSda9sE8PVQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/04/2014 01:25 PM, Cedric Blancher wrote:
> On 4 September 2014 11:33, Jurjen Bokma <j.bokma@rug.nl> wrote:
>> You use cross realm authentication, so that your NFS client may obtain
>> tickets for servers that are not in its own realm.
> 
> What if I cannot use cross realm authentication? For example if both
> realms do not like each other?
> What if I really have to kinit into multiple realms? Kerberos since
> 1.10 can do that and klist now has a new flag -A to list all entries
> if KRB5CCNAME points to a directory, e.g.
> KRB5CCNAME=DIR:/tmp/krbcc$UID/
> 
> Ced
> 
I tried that about a year ago, and failed to make it work.
As far as I know, gssd always picks the same key to authenticate with. I
did offer a patch on this list a couple of weeks ago that uses a
krb5.conf appdefaults option to configure *which* key, but that one
still doesn't make it possible to pick a different key for different shares.

Sorry
Jurjen

