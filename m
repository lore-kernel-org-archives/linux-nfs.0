Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:34591 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934842AbcIFWvw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2016 18:51:52 -0400
Received: by mail-qk0-f175.google.com with SMTP id t7so234441443qkh.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Sep 2016 15:51:52 -0700 (PDT)
Message-ID: <1473202308.2505.8.camel@redhat.com>
Subject: Re: 4.6, 4.7 slow ifs export with more than one client.
From: Jeff Layton <jlayton@redhat.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 06 Sep 2016 18:51:48 -0400
In-Reply-To: <3362C9C5-7F87-462C-B1C4-D704B45B84BE@linuxhacker.ru>
References: <6C329B27-111A-4B16-84F4-7357940EBC01@linuxhacker.ru>
         <1473172215.13234.8.camel@redhat.com>
         <A7375479-E5A6-47FE-915E-8E2B6E5CF012@linuxhacker.ru>
         <1473175124.13234.16.camel@redhat.com>
         <05AA5CE8-143C-4CB7-AFF0-36BE495AA328@linuxhacker.ru>
         <1473177653.13234.22.camel@redhat.com>
         <3362C9C5-7F87-462C-B1C4-D704B45B84BE@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-09-06 at 12:29 -0400, Oleg Drokin wrote:
> On Sep 6, 2016, at 12:00 PM, Jeff Layton wrote:
> > 
> > 
> > Shrug...feel free to propose a better scheme for generating unique
> > ids
> > if you can think of one. Unfortunately, there are always cases when
> > these mechanisms for getting a persistent+unique id break down.
> > 
> > That's the reason that nfs provides an interface to allow setting a
> > uniquifier from userland via module param.
> 
> Fair enough, though I guess module parameter is not really a super
> convenient place
> for it when you run off nfs-root.
> I guess you were not really enticed with the mac address idea too ;)
> 

Which mac address? It's not always a given that the host will initialze
them in the same order when you have multiple interfaces, even if the
hardware doesn't change out from under you.

This is just one of those classic "punt the solution to userland" sort
of problems that's just really hard to fix in the kernel in a way that
will always work.

> Anyway, thank you very much for your help, now I have some better
> idea of what's going on and what to try next.

No problem. Diagnosing these sorts of problems can be pretty difficult.

Note too that earlier versions of the client had a length limitation on
this string, which could cause similar problems even when the hostnames
are already set if they were very long names and only differed at the
end. commit 873e385116b2cc5c7daca8f51881371fadb90970 fixes that
problem.

-- 
Jeff Layton <jlayton@redhat.com>
