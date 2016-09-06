Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:54396 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933333AbcIFQ3l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Sep 2016 12:29:41 -0400
Subject: Re: 4.6, 4.7 slow ifs export with more than one client.
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1473177653.13234.22.camel@redhat.com>
Date: Tue, 6 Sep 2016 12:29:33 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <3362C9C5-7F87-462C-B1C4-D704B45B84BE@linuxhacker.ru>
References: <6C329B27-111A-4B16-84F4-7357940EBC01@linuxhacker.ru> <1473172215.13234.8.camel@redhat.com> <A7375479-E5A6-47FE-915E-8E2B6E5CF012@linuxhacker.ru> <1473175124.13234.16.camel@redhat.com> <05AA5CE8-143C-4CB7-AFF0-36BE495AA328@linuxhacker.ru> <1473177653.13234.22.camel@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 6, 2016, at 12:00 PM, Jeff Layton wrote:
> 
> Shrug...feel free to propose a better scheme for generating unique ids
> if you can think of one. Unfortunately, there are always cases when
> these mechanisms for getting a persistent+unique id break down.
> 
> That's the reason that nfs provides an interface to allow setting a
> uniquifier from userland via module param.

Fair enough, though I guess module parameter is not really a super convenient place
for it when you run off nfs-root.
I guess you were not really enticed with the mac address idea too ;)

Anyway, thank you very much for your help, now I have some better
idea of what's going on and what to try next.