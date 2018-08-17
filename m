Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lisa.pbhware.com ([96.251.22.156]:12664 "EHLO lisa.pbhware.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726066AbeHQDWS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Aug 2018 23:22:18 -0400
Received: from [134.71.248.24] (host-134-71-248-24.allocated.cpp.edu [134.71.248.24])
        by smtp.pbhware.com (OpenSMTPD) with ESMTPSA id e1e0f0f9 (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO)
        for <linux-nfs@vger.kernel.org>;
        Thu, 16 Aug 2018 17:14:29 -0700 (PDT)
To: linux-nfs@vger.kernel.org
From: "Paul B. Henson" <henson@acm.org>
Subject: nfs4-acl-tools vs ZFS NFSv4 based acl internals
Message-ID: <571bacd0-759d-af39-a998-d96f30ecb8e2@acm.org>
Date: Thu, 16 Aug 2018 17:14:27 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm currently working on getting the native NFSv4 based ZFS ACL working 
in the zfs on linux port. As there isn't currently a kernel interface 
for this type of ACL, I'm using the same system.nfs4_acl extended 
attribute to interface touser space as the NFS client, and the 
nfs4-acl-tools implementation to manage them.

I ran into an issue which I traced down to a discrepancy between the 
definitions for the flags between ZFS and the nfs4-acl-tools package:

 From zfs/acl.h:

    #define ACE_INHERITED_ACE               0x0080
    #define ACE_OWNER                       0x1000
    #define ACE_GROUP                       0x2000
    #define ACE_EVERYONE                    0x4000

 From nfs4-acl-tools:

    #define NFS4_ACE_OWNER                        0x00000080
    #define NFS4_ACE_GROUP                        0x00000100
    #define NFS4_ACE_EVERYONE                     0x00000200

Does anyone know why these are different? I couldn't find these defined 
in the NFSv4 RFC, so I'm not sure where either side got the specific 
values they are using. For now, I am mapping between the values as I go 
between the zfs internals and the extended attribute values. However, 
that is not ideal, particularly as it prevents passing the inherited ace 
flag given the value conflicts between the two.
