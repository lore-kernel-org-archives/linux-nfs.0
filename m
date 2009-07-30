From: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
Subject: AutoFS+NFSv4 server down = Client LOOOOONG timeout.
Date: Thu, 30 Jul 2009 09:38:43 -0300
Message-ID: <f6ce31e30907300538p5d8f54e9v6e4b30630ded2852@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f188.google.com ([209.85.212.188]:61946 "EHLO
	mail-vw0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbZG3Mpa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2009 08:45:30 -0400
Received: by vws26 with SMTP id 26so42623vws.21
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2009 05:45:30 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work with
Kerberos and AutoFS, but i got a problem: If NFS server goes down i
get a LOOOOOOONG mount timeout on CentOS 5.3 (updated) NFSv4 client...

Since i need mount some (3 to 6) dirs at user logon process, if mount
hangs, user logon hangs. Then i want configure it to timeout (if
server down) after 10-15 secs (MAX) on each mount attempt.

I already make a lab and tried a LOT of combinations, there my
findings (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) using
basic command (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
sec=krb5,proto=<tcp/udp>) from NFS client:

- Once i try access mount point using AutoFS (proto=tcp OR proto=udp)
it hangs for 189 secs (3m9s: real  3m9.001s)  until show error (mount:
mount to NFS server '172.16.0.10' failed: timed out (giving up))

Mounting manually using NFSv4 i got same timeouts of AutoFS.

The only way to get a lower timeout value is using only
proto=udp,retry=0 (AND not using Kerberos...sec=krb5) any another
combination i get 3m9s (sec=krb5,proto=tcp)


I tried change another NFS mount options putting a lower value (timeo,
retrans, etc) but they make no difference.... But i want
NFSv4/TCP/Kerberos and a timeout lower then 15 secs... :(

I'm using these packages (server and client side):
autofs-5.0.1-0.rc2.102.el5_3.1
nfs-utils-1.0.9-40.el5
kernel-2.6.18-128.1.16.el5

The only way to resolve this behavior is changing the source code?
There's no way to lower timeout with NFSv4/TCP in this case ?

Thanks.
