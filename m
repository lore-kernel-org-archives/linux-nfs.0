Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:43851 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753691Ab2GABxS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jun 2012 21:53:18 -0400
Received: by pbbrp8 with SMTP id rp8so6097538pbb.19
        for <linux-nfs@vger.kernel.org>; Sat, 30 Jun 2012 18:53:18 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 1 Jul 2012 02:53:18 +0100
Message-ID: <CAPD_G3L0wwzCWyoPJp_sKpuQ0J7+avn-ejEn-WnXf81zr=-LqA@mail.gmail.com>
Subject: Linux NFSv4 client uses returned delegation in subsequent READ
 resulting in hang (BAD_STATEID)
From: "Charles 'Boyo" <charlesboyo@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.

I have repeatedly had Linux NFS clients hang while trying to access
files on a NFSv4 mount (Solaris).
Investigations revealed that this client is using a delegation that it
has already returned, resulting in the BAD_STATEID error.
Unfortunately, it then proceeds to hammer the server with these
"doomed" requests, resulting in the client-side unresponsiveness and
constant network traffic.

A sample trace can be found at http://pastebin.centos.org/39046
As shown, the READ in frame 10 (line 112) follows the DELEGRETURN in
frame 9 which results in the error. This READ was then repeated
infinitely until either the server or client was restarted.
Disabling delegations on the server-side caused the problem to cease.
So what is wrong with delegations on the client-side?

I am using the latest nfs-utils packages and my mount options are as
shown below:

# cat /etc/redhat-release
CentOS release 6.2 (Final)

# uname -r
2.6.32-220.4.1.el6.x86_64

# rpm -qa '*nfs*'
nfs-utils-lib-1.1.5-4.el6.x86_64
nfs-utils-1.2.3-15.el6_2.1.x86_64

# grep nfs4 /proc/mounts
10.51.1.6:/SharedFolder/ /var/LocalMountPoint nfs4
rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.51.1.34,minorversion=0,local_lock=none,addr=10.51.1.6
0 0

Regards,

Charles
