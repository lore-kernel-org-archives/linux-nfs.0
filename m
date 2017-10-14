Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:43898 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753841AbdJNO7v (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Oct 2017 10:59:51 -0400
Received: by mail-oi0-f48.google.com with SMTP id c77so19086098oig.0
        for <linux-nfs@vger.kernel.org>; Sat, 14 Oct 2017 07:59:50 -0700 (PDT)
MIME-Version: 1.0
From: Ziemowit Pierzycki <ziemowit@pierzycki.com>
Date: Sat, 14 Oct 2017 09:59:49 -0500
Message-ID: <CAOiTGH=Hjmn_828yoNjuv2FnEg1NGMUicVZY3s74j0sXEs4szg@mail.gmail.com>
Subject: NFS rejecting connections
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
I have two NFS servers that appear to have the same issue.  They're
both Fedora 25 based and none of the clients can connect while
retrying to infinity.  If I restart the server it works for a little
before the same thing happening.

Turning on debugging shows the following:

[171565.851530] svc: socket ffff940c3a5ef000(inet ffff940d7db626c0), busy=1
[171566.026535] svc: socket ffff940d7ac0c000(inet ffff940d7db87440), busy=1
[171570.032880] svc: socket ffff940d9c253000(inet ffff940d999b9f00), busy=1
[171576.915841] svc: socket ffff94143ce1d000(inet ffff940d7db62e80), busy=1
[171578.360395] svc: socket ffff94128bba4000(inet ffff940d999b8f80), busy=1
[171578.828178] svc: socket ffff94143919b000(inet ffff940d7db83640), busy=1
[171578.828198] svc: socket ffff94143919b000(inet ffff940d7db83640), busy=1
[171579.930641] svc: socket ffff940d89e71000(inet ffff940d999b8000), busy=1
[171579.930662] svc: socket ffff940d89e71000(inet ffff940d999b8000), busy=1
[171579.930680] svc: socket ffff940d89e71000(inet ffff940d999b8000), busy=1
[171580.024655] svc: socket ffff940d9c253000(inet ffff940d999b9f00), busy=1
[171580.913639] svc: socket ffff940d3f539000(inet ffff940d7db65d00), busy=1
[171582.400198] NFSD: laundromat service - starting
[171582.400202] NFSD: laundromat_main - sleeping for 90 seconds
[171589.539121] svc: socket ffff940ac592d000(inet ffff940d97b55540), busy=1
[171589.539284] svc: socket ffff940ac592d000(inet ffff940d97b55540), busy=1
[171590.040366] svc: socket ffff940d9c253000(inet ffff940d999b9f00), busy=1
[171590.591191] svc: socket ffff94128bba1000(inet ffff940d7db607c0), busy=1
[171598.027702] svc: socket ffff94143919b000(inet ffff940d7db83640), busy=1
[171599.863801] svc: socket ffff94128bba4000(inet ffff940d999b8f80), busy=1
[171599.863836] svc: socket ffff94128bba4000(inet ffff940d999b8f80), busy=1
[171600.056109] svc: socket ffff940d9c253000(inet ffff940d999b9f00), busy=1
[171604.354706] svc: socket ffff940ac592d000(inet ffff940d97b55540), busy=1
[171608.585185] svc: socket ffff94057a6da000(inet ffff940d999bdd00), busy=1
[171609.498365] svc: socket ffff940c3a5ef000(inet ffff940d7db626c0), busy=1
[171609.790704] svc: socket ffff94128bba1000(inet ffff940d7db607c0), busy=1
[171610.071868] svc: socket ffff940d9c253000(inet ffff940d999b9f00), busy=1
[171616.141902] svc: socket ffff940d7ac08000(inet ffff940d7db81f00), busy=1
[171620.055620] svc: socket ffff940d9c253000(inet ffff940d999b9f00), busy=1

Then there is a single nfsd process that has a very high load:

# cat /proc/4192/stack
[<ffffffffffffffff>] 0xffffffffffffffff

# rpcinfo
   program version netid     address                service    owner
    100000    4    tcp6      ::.0.111               portmapper superuser
    100000    3    tcp6      ::.0.111               portmapper superuser
    100000    4    udp6      ::.0.111               portmapper superuser
    100000    3    udp6      ::.0.111               portmapper superuser
    100000    4    tcp       0.0.0.0.0.111          portmapper superuser
    100000    3    tcp       0.0.0.0.0.111          portmapper superuser
    100000    2    tcp       0.0.0.0.0.111          portmapper superuser
    100000    4    udp       0.0.0.0.0.111          portmapper superuser
    100000    3    udp       0.0.0.0.0.111          portmapper superuser
    100000    2    udp       0.0.0.0.0.111          portmapper superuser
    100000    4    local     /run/rpcbind.sock      portmapper superuser
    100000    3    local     /run/rpcbind.sock      portmapper superuser
    100024    1    udp       0.0.0.0.131.70         status     29
    100024    1    tcp       0.0.0.0.221.245        status     29
    100024    1    udp6      ::.170.79              status     29
    100024    1    tcp6      ::.143.15              status     29
    100005    1    udp       0.0.0.0.78.80          mountd     superuser
    100005    1    tcp       0.0.0.0.78.80          mountd     superuser
    100005    1    udp6      ::.78.80               mountd     superuser
    100005    1    tcp6      ::.78.80               mountd     superuser
    100005    2    udp       0.0.0.0.78.80          mountd     superuser
    100005    2    tcp       0.0.0.0.78.80          mountd     superuser
    100005    2    udp6      ::.78.80               mountd     superuser
    100005    2    tcp6      ::.78.80               mountd     superuser
    100005    3    udp       0.0.0.0.78.80          mountd     superuser
    100005    3    tcp       0.0.0.0.78.80          mountd     superuser
    100005    3    udp6      ::.78.80               mountd     superuser
    100005    3    tcp6      ::.78.80               mountd     superuser
    100003    3    tcp       0.0.0.0.8.1            nfs        superuser
    100003    4    tcp       0.0.0.0.8.1            nfs        superuser
    100227    3    tcp       0.0.0.0.8.1            nfs_acl    superuser
    100003    3    udp       0.0.0.0.8.1            nfs        superuser
    100227    3    udp       0.0.0.0.8.1            nfs_acl    superuser
    100003    3    tcp6      ::.8.1                 nfs        superuser
    100003    4    tcp6      ::.8.1                 nfs        superuser
    100227    3    tcp6      ::.8.1                 nfs_acl    superuser
    100003    3    udp6      ::.8.1                 nfs        superuser
    100227    3    udp6      ::.8.1                 nfs_acl    superuser
    100021    1    udp       0.0.0.0.231.220        nlockmgr   superuser
    100021    3    udp       0.0.0.0.231.220        nlockmgr   superuser
    100021    4    udp       0.0.0.0.231.220        nlockmgr   superuser
    100021    1    tcp       0.0.0.0.145.133        nlockmgr   superuser
    100021    3    tcp       0.0.0.0.145.133        nlockmgr   superuser
    100021    4    tcp       0.0.0.0.145.133        nlockmgr   superuser
    100021    1    udp6      ::.188.96              nlockmgr   superuser
    100021    3    udp6      ::.188.96              nlockmgr   superuser
    100021    4    udp6      ::.188.96              nlockmgr   superuser
    100021    1    tcp6      ::.173.23              nlockmgr   superuser
    100021    3    tcp6      ::.173.23              nlockmgr   superuser
    100021    4    tcp6      ::.173.23              nlockmgr   superuser

And all the clients are trying to reconnect:

nfs: server elkpinfnas03.corp.vibes.com OK
nfs: server elkpinfnas03.corp.vibes.com OK
nfs: server elkpinfnas03.corp.vibes.com not responding, still trying

Any help would be greatly appreciated.  Thank you.
