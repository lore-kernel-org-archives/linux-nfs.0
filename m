From: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
Subject: Re: AutoFS+NFSv4 server down = Client LOOOOONG timeout.
Date: Thu, 6 Aug 2009 21:17:03 -0300
Message-ID: <f6ce31e30908061717k320969a1v63242f3dab29cff5@mail.gmail.com>
References: <f6ce31e30907300538p5d8f54e9v6e4b30630ded2852@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f183.google.com ([209.85.212.183]:57231 "EHLO
	mail-vw0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416AbZHGARF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 20:17:05 -0400
Received: by vws13 with SMTP id 13so1200382vws.22
        for <linux-nfs@vger.kernel.org>; Thu, 06 Aug 2009 17:17:05 -0700 (PDT)
In-Reply-To: <f6ce31e30907300538p5d8f54e9v6e4b30630ded2852-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anyone??

2009/7/30 Carlos Andr=E9 <candrecn@gmail.com>:
> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work with
> Kerberos and AutoFS, but i got a problem: If NFS server goes down i
> get a LOOOOOOONG mount timeout on CentOS 5.3 (updated) NFSv4 client..=
=2E
>
> Since i need mount some (3 to 6) dirs at user logon process, if mount
> hangs, user logon hangs. Then i want configure it to timeout (if
> server down) after 10-15 secs (MAX) on each mount attempt.
>
> I already make a lab and tried a LOT of combinations, there my
> findings (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) using
> basic command (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -=
o
> sec=3Dkrb5,proto=3D<tcp/udp>) from NFS client:
>
> - Once i try access mount point using AutoFS (proto=3Dtcp OR proto=3D=
udp)
> it hangs for 189 secs (3m9s: real =A03m9.001s) =A0until show error (m=
ount:
> mount to NFS server '172.16.0.10' failed: timed out (giving up))
>
> Mounting manually using NFSv4 i got same timeouts of AutoFS.
>
> The only way to get a lower timeout value is using only
> proto=3Dudp,retry=3D0 (AND not using Kerberos...sec=3Dkrb5) any anoth=
er
> combination i get 3m9s (sec=3Dkrb5,proto=3Dtcp)
>
>
> I tried change another NFS mount options putting a lower value (timeo=
,
> retrans, etc) but they make no difference.... But i want
> NFSv4/TCP/Kerberos and a timeout lower then 15 secs... :(
>
> I'm using these packages (server and client side):
> autofs-5.0.1-0.rc2.102.el5_3.1
> nfs-utils-1.0.9-40.el5
> kernel-2.6.18-128.1.16.el5
>
> The only way to resolve this behavior is changing the source code?
> There's no way to lower timeout with NFSv4/TCP in this case ?
>
> Thanks.
>
