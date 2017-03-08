Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35731 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752985AbdCHVvl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Mar 2017 16:51:41 -0500
Received: by mail-qk0-f180.google.com with SMTP id v125so88299496qkh.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Mar 2017 13:51:01 -0800 (PST)
Received: from cs.brown.edu ([128.148.231.11])
        by smtp.gmail.com with ESMTPSA id m12sm2962247qtm.45.2017.03.08.13.51.00
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 13:51:00 -0800 (PST)
Date: Wed, 8 Mar 2017 16:50:58 -0500
From: John Bazik <john_bazik@brown.edu>
To: linux-nfs@vger.kernel.org
Subject: access(2) inaccurately reports execute permissions
Message-ID: <20170308215058.GO27384@cs.brown.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have evidence that the system call access(2), with mode set to X_OK,
does not accurately report execute permissions for a file mounted via
NFS4 and with execute provided by an NFS4 acl.

Here's a transcript:

root@radio:/testmnt# nfs4_getfacl acltestjan3017/testacls/f.test301.test261.400.u+test314=5
A::OWNER@:rtTcCy
A::test314@ad.brown.edu:rxtcy
A::GROUP@:tcy
A::EVERYONE@:tcy
root@radio:/testmnt# ./runas -k test314 ./test_access acltestjan3017/testacls/f.test301.test261.400.u+test314=5
USER  999999314 (test314) 999999314 (test314) 999999314 (test314)
GROUP 1427981 (user-test314) 1427981 (user-test314) 1427981 (user-test314)
KRB5  test314@AD.BROWN.EDU
SUPPL GROUPS: user-test314 
r-- acltestjan3017/testacls/f.test301.test261.400.u+test314=5
root@radio:/testmnt# ./runas -k test314 acltestjan3017/testacls/f.test301.test261.400.u+test314=5

My script "runas" su's and acquires kerberos credentials for the given
user, and executes the given command.

My command test_access (a c program) prints all process credentials
and then runs access(2) separately with R_OK, W_OK and X_OK modes,
and prints the result.

The second line shows that access(2) indicates that user test314 has only
read rights, despite the user ACE for test314.  The last line shows that
test314 can, in fact, execute the file (which is empty - no error).

My client is a Debian Jessie system with these various versions of things:

Debian            8.6
Kernel            3.16.0-4-amd64
acl               2.2.52-2
libgssapi-krb5-2  1.12.1+dfsg-19+deb8u2
librpcsecgss3     (not installed)
nfs-utils         (? don't see it)
util-linux        2.25.2-6

The server is an EMC Isilon.

John
