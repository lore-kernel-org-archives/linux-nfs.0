Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp23.rug.nl ([129.125.60.104]:36217 "EHLO smtp23.rug.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754511AbaIDJd4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2014 05:33:56 -0400
Received: from mail-wi0-f171.google.com ([172.23.16.207])
	by smtp23.rug.nl (8.14.7/8.14.7) with ESMTP id s849Xr0w001773
	for <linux-nfs@vger.kernel.org>; Thu, 4 Sep 2014 11:33:54 +0200
Received: by mail-wi0-f171.google.com with SMTP id hi2so695940wib.10
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 02:33:53 -0700 (PDT)
Message-ID: <540831FE.1010208@rug.nl>
Date: Thu, 04 Sep 2014 11:33:50 +0200
From: Jurjen Bokma <j.bokma@rug.nl>
MIME-Version: 1.0
To: Cedric Blancher <cedric.blancher@gmail.com>
CC: "<kerberos@mit.edu>" <kerberos@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: How to use NFS with multiple principals in different realms?
References: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com>
In-Reply-To: <CALXu0Ue9z-xbFk9hhsvu4c38qqmd0Wwupk2LvL99rwoAcRMqOw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

You use cross realm authentication, so that your NFS client may obtain
tickets for servers that are not in its own realm.

To allow for cross-realm authentication from your own MYREALM.NET (where
te client is) to your neighbour's HISREALM.ORG (the realm of the
server), you basically create *in*each*realm* a principal
krbtgt/MYREALM.NET@HISREALM.ORG.
Both principals must be identical. They have to have the same name, the
same encryption types, and the same kvno.
After that, it's a matter of configuring the krb5.conf right: tell the
Kerberos servers which machine is in which realm if DNS doesn't do that.
Debian bug #571244 may also come into play on RHEL?

I've got step by step documentation for an Ubuntu NFS client with
Kerberos served by Heimdal under Debian and Windows AD respectively. But
I haven't anonymized the text yet, so I can't put it online immediately.
Would it help you if I anonymize it soon, or can you work it our from
just the above hints?

Regards
Jurjen


On 09/04/2014 11:04 AM, Cedric Blancher wrote:
> How can I use NFS with kerberos krb5p auth when I want to use NFS
> filesystems which come from different realms?
> 
> I know klist -A can show all tickets I got from all realms I kinit to
> - but how can NFS use them?
> 
> OS is RHEL7
> 
> Ced
> 

