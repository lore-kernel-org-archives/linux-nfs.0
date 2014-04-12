Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:48832 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756119AbaDLKPm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Apr 2014 06:15:42 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so1751174igb.5
        for <linux-nfs@vger.kernel.org>; Sat, 12 Apr 2014 03:15:42 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 12 Apr 2014 12:15:42 +0200
Message-ID: <CALXu0UdKKtyoYq0t8hhOw=zBpJZu2unHR-A8MF3EgcON=kiwnw@mail.gmail.com>
Subject: Accessing Kerberos NFS version 4 (not 2, 3) via /net automounter with
 kinit only (no /etc/krb5.conf access)
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, how hard is it to get this working on Linux? Or does it already?

Ced

---------- Forwarded message ----------
From: Wang Shouhua <shouhuaw@gmail.com>
Date: Sat, Apr 12, 2014 at 11:24 AM
Subject: Accessing Kerberos NFS version 4 (not 2, 3) via /net
automounter with kinit only (no /etc/krb5.conf access)
To: Kerberos@mit.edu


Lets recap:

1. Requirements:
- Linux or Solaris
- NFS automounter set up at /net
- Kerberos5 configured for realm EXAMPLE2.COM, rpc.gssd running
- A NFS server (version 4 only) nfsserver.most.gov.cn exists in the
realm MOST.GOV.CN, with a subdir of test3

2. Goal:
A user provides his password to obtain a ticket for user2@MOST.GOV.CN
(optionally nfs@MOST.GOV.CN, if this is a requirement to do a mount),
and is then able to cd into /net/nfsserver.most.gov.cn/test3, and do a
successful ls -al there

Is that possible?

Wang

---------- Forwarded message ----------
From: Will Fiveash <will.fiveash@oracle.com>
Date: 11 April 2014 22:14
Subject: Re: Accessing Kerberos NFS via /net automounter with kinit
only (no /etc/krb5.conf access)
To: Wang Shouhua <shouhuaw@gmail.com>
Cc: Kerberos@mit.edu


On Tue, Apr 01, 2014 at 06:00:45PM +0200, Wang Shouhua wrote:
> I am on Solaris 10U4 - can I access a NFS filesystem with (mandatory)
> krb5p authentication via the Solaris /net automounter with kinit only,
> without having r/w access to /etc/krb5.conf access)?

You'll need to have Solaris krb configured which stores its config in
/etc/krb5 not /etc as is the MIT default.  You'll also need read access
to /etc/krb5/krb5.conf and have the system properly configured to do NFS
with krb in general (read the Solaris 10 online docs).

Beyond that, whether a user kinit'ing is enough depends on which version
of NFS you are using.  On the client side NFSv3 sec=krb5p shares will
automount if the user triggering the mount has a krb cred in their
ccache (klist will show that) and does not require any keys in the
system keytab nor does it require root to have a krb cred in general.

NFSv4 on the other hand does require that the root on the NFS client
system have a krb cred in its ccache.  This can be done either by
running kinit as root or having at least one set of keys for either the
root/<host> or host/<host> service princ in the system keytab which will
be automatically used to acquire a krb cred for root.

On the client system "nfsstat -m" will show what version of NFS is being
used.

--
Will Fiveash
Oracle Solaris Software Engineer


--
Wang Shouhua - shouhuaw@gmail.com
中华人民共和国科学技术部 - HTTP://WWW.MOST.GOV.CN


________________________________________________
Kerberos mailing list           Kerberos@mit.edu
https://mailman.mit.edu/mailman/listinfo/kerberos

-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
