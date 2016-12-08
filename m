Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.46]:39595 "EHLO minas.ics.muni.cz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932291AbcLHVWy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Dec 2016 16:22:54 -0500
Date: Thu, 8 Dec 2016 22:22:38 +0100
From: Lukas Hejtmanek <xhejtman@gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Andy Adamson <androsadamson@gmail.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: RFC rpc.gssd enhancement
Message-ID: <20161208212238.ctyshbcpz7afzrxv@ics.muni.cz>
References: <20161129184843.jrwbnytggrz6kdir@ics.muni.cz>
 <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
 <20161202114134.rvzqptnsqo3odxay@ics.muni.cz>
 <CAHVgHyU6LQak3O4ybR0H3whWCKUdfz2bxLvEGi9uFM1EX+e=Eg@mail.gmail.com>
 <20161202134638.4ghyb5wnnwata4ec@ics.muni.cz>
 <CAHVgHyVWqNZv55dH3hhZ-0XDsd4c79OW_R6Ze02uhv-nqePpPQ@mail.gmail.com>
 <20161202142847.vyhp6ogtu6gvuabf@ics.muni.cz>
 <CAHVgHyW6fo1b2LSjxq73n7wQkR9r0JEvwzxHdb3X9p+gSpLQ1Q@mail.gmail.com>
 <20161208123616.nndod3snzoeyr565@ics.muni.cz>
 <CAN-5tyGCTkqX7qmR+kjsGTtjqjMH6-PJ4VXWnP0+ruXzz5B+Cg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <CAN-5tyGCTkqX7qmR+kjsGTtjqjMH6-PJ4VXWnP0+ruXzz5B+Cg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 08, 2016 at 04:11:38PM -0500, Olga Kornievskaia wrote:
> Why is "kinit" accessing ~/.krb5/config? Typically kinit will only
> access /etc/krb5.conf.
> 
> You are describing a catch-22 system. You want to create credentials
> but to create credentials you need to access a file that is protected
> by the credentials. This is a badly designed setup.
> 
> kinit normally does not require access into something that is
> protected by credentials gotten by kinit.
> 
> Your solution is to provide your user with "kinit" that does not
> access ~/.krb5/config. Please describe the need for that file and why
> it can't be satisfied using machine global /etc/krb5.conf.

debian heimdal 1.6~rc2+dfsg-9  opens ~/.krb5/config and ~/.rnd files. 
dunno why.

MIT implementation does not seem to access $HOME.

-- 
Luká¹ Hejtmánek
