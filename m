Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f180.google.com ([209.85.217.180]:41146 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754616Ab3FMHro (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jun 2013 03:47:44 -0400
Received: by mail-lb0-f180.google.com with SMTP id o10so7055267lbi.11
        for <linux-nfs@vger.kernel.org>; Thu, 13 Jun 2013 00:47:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJO99TmfCTYgyrwgUWUmFNGjhQhtHzA7+YDby_MNH2Bjt5tk2g@mail.gmail.com>
References: <CAJO99TmfCTYgyrwgUWUmFNGjhQhtHzA7+YDby_MNH2Bjt5tk2g@mail.gmail.com>
Date: Thu, 13 Jun 2013 09:47:43 +0200
Message-ID: <CAJO99T=ugw6bk_jvv8dEbBiRLCccRXQ+TjFVnZTPhOc8p=KuGw@mail.gmail.com>
Subject: Re: caching issue with nocto
From: =?ISO-8859-1?Q?Bj=F8rnar_Ness?= <bjornar.ness@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have not yet received any feedback on this issue. Can someone please take
a look into this?

Seems like updating mtime on the folder from different client is causes nocto to
stop working on a mount (or a subfolder of the mount)

client1:

mount -t nfs -o
vers=3,noatime,nodiratime,noacl,ac,sharecache,lookupcache=all,nocto
10.30.0.11/foo /mnt
while true; do time cat /mnt/linux-headers/*.h >/dev/null ; done

real 0m1.037s
user 0m0.008s
sys 0m0.088s

real 0m0.021s
user 0m0.008s
sys 0m0.008s

[...]

client2:

same mount,

touch /mnt/linux-headers


What happends (after few secs) is client1 times goes to over a sec and
stays there for infinity.

a -o remount (run a few times) solves problem (until client2 touches a
folder again..)

--
Bj(/)rnar
