Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lisa.pbhware.com ([96.251.22.156]:41212 "EHLO lisa.pbhware.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726916AbeHVDHJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Aug 2018 23:07:09 -0400
Subject: Re: nfs4-acl-tools 0.3.5
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <20180807193736.GA18187@fieldses.org>
 <20180821165130.GA14413@fieldses.org>
From: "Paul B. Henson" <henson@acm.org>
Message-ID: <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
Date: Tue, 21 Aug 2018 16:44:38 -0700
MIME-Version: 1.0
In-Reply-To: <20180821165130.GA14413@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/21/2018 9:51 AM, J. Bruce Fields wrote:
> One more nfs4-acl-tools release.  This removes the GUI, which appears to

I had recently posted an inquiry regarding the nfs4-acl-tools; I don't 
believe I saw a response but if you are maintaining them perhaps you 
might know?

I'm currently working on implementing support for the native NFSv4 ACL 
in the ZFS on Linux port, using nfs4-acl-tools as the mechanism for 
viewing and updating them. I noticed a discrepancy between the 
definitions in the ZFS NFSv4 ACL include file versus the ones in the 
nfs4-acl-tools headers.

Specifically, in zfs:

#define ACE_INHERITED_ACE               0x0080
#define ACE_OWNER                       0x1000
#define ACE_GROUP                       0x2000
#define ACE_EVERYONE                    0x4000

Whereas in nfs4-acl-tools:

#define NFS4_ACE_OWNER                        0x00000080
#define NFS4_ACE_GROUP                        0x00000100
#define NFS4_ACE_EVERYONE                     0x00000200

I'm not sure where these values came from, I don't see them in the NFSv4 
RFC. Do you happen to have any idea where the values used in the 
nfs4-acl-tools came from and why they might be different than those used 
by zfs?

Thanks much…
