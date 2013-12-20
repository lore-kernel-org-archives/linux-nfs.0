Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f176.google.com ([209.85.212.176]:32866 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342Ab3LTRKq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Dec 2013 12:10:46 -0500
Received: by mail-wi0-f176.google.com with SMTP id hq4so8706512wib.15
        for <linux-nfs@vger.kernel.org>; Fri, 20 Dec 2013 09:10:45 -0800 (PST)
Received: from pavillion.lo (1.200.208.46.dyn.plus.net. [46.208.200.1])
        by mx.google.com with ESMTPSA id ko3sm3019494wjb.23.2013.12.20.09.10.42
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 09:10:44 -0800 (PST)
Message-ID: <52B47A12.2070202@garethwilliams.me.uk>
Date: Fri, 20 Dec 2013 17:10:42 +0000
From: Gareth Williams <gareth@garethwilliams.me.uk>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Question ref Running NFS at V4 Only
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm trying to run NFS with protocol version 4 only (that is, with v2 & 
v3 disabled) on a CentOS 6.5 install running as a KVM guest.

The RedHat documentation (amongst others) states that rpcbind isn't 
needed with v4, but if I start nfs without rpcbind I get errors.

I've spent a couple of days (on and off) on Google trying to get an 
answer and have posted on the CentOS forum, but the nearest I can find  
is an archive on this mailing list from over two years ago (and it's not 
identical):-

http://www.spinics.net/lists/linux-nfs/msg16907.html

In /etc/sysconfig/nfs I have:-

MOUNTD_NFS_V2="no"
MOUNTD_NFS_V3="no"

RPCNFSDARGS="-N 2 -N 3"

When I attempt to start NFS either using the init scripts  or manually 
with:-

rpc.nfsd -N 2 -N 3

I get:-

rpc.nfsd: writing fd to kernel failed: errno 111 (Connection refused)
rpc.nfsd: unable to set any sockets for nfsd

The mailing list archive's answer was that the kernel was too old, so I 
installed 3.10.24 from elrepo but the symptom doesn't change.

If I start rpcbind, then everything works, but as far as I can see, I 
shouldn't have to do that unless I'm supporting v2 & v3.

Finally, please accept my apologies for wasting your time if I've missed 
something obvious.

Kind regards,

Gareth
