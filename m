Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:54047 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759804Ab3CHRLu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 12:11:50 -0500
Received: from cpe-70-124-70-187.austin.res.rr.com ([70.124.70.187] helo=[192.168.1.73])
	by youngberry.canonical.com with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.71)
	(envelope-from <dave.chiluk@canonical.com>)
	id 1UE0pg-0006yy-Jp
	for linux-nfs@vger.kernel.org; Fri, 08 Mar 2013 17:11:48 +0000
Message-ID: <513A1BD1.6060709@canonical.com>
Date: Fri, 08 Mar 2013 11:11:45 -0600
From: Dave Chiluk <dave.chiluk@canonical.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFSv4 setattr null-terminates strings
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As of commit 57e62324e469e092ecc6c94a7a86fe4bd6ac5172, the SETATTR nfsv4
command now null terminates fattr_owner and fattr_owner_group.

Here is an example excerpt from a tcpdump
Opcode: SETATTR (34)
    stateid
        [StateID Hash: 0xafa9]
        seqid: 0x00000000
        Data: 000000000000000000000000
    obj_attributes
        attrmask
            recc_attr: FATTR4_OWNER_GROUP (37)
                fattr4_owner_group: groupname@domainname.com
                    length: 25

This means that even though there are actually 24 characters in
groupname@domainname.com, we now send 24 characters + 1 null character.
Hence the total length of 25.  Previously the client would send just the
24 characters and set length to 24.

This isn't an issue for communication with other Linux machines, but it
is an issue for interaction with AIX machines.  As is discussed here.
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1101292

I attempted to read the RFC available here
http://tools.ietf.org/html/rfc5661, but have not been able to find a
statement instructing one way or the other.

So the question becomes, is it correct for linux to be sending this null
terminator when read against the RFC, or is it AIX's responsibility to
handle null-terminated strings?

Thank you,
Dave.
