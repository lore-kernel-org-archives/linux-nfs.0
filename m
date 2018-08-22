Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48482 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726916AbeHVDzZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Aug 2018 23:55:25 -0400
Date: Tue, 21 Aug 2018 20:33:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Paul B. Henson" <henson@acm.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4-acl-tools 0.3.5
Message-ID: <20180822003301.GA17500@fieldses.org>
References: <20180807193736.GA18187@fieldses.org>
 <20180821165130.GA14413@fieldses.org>
 <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 21, 2018 at 04:44:38PM -0700, Paul B. Henson wrote:
> On 8/21/2018 9:51 AM, J. Bruce Fields wrote:
> >One more nfs4-acl-tools release.  This removes the GUI, which appears to
> 
> I had recently posted an inquiry regarding the nfs4-acl-tools; I
> don't believe I saw a response but if you are maintaining them
> perhaps you might know?

Sorry, yes, I saw the question but hadn't gotten a chance to look at it.

In the wire protocol there's no need for such constants.  An ACE can
have one of the special strings OWNER@, GROUP@, or EVERYONE@ in the
owner field, and that's all you need.  Without actually looking at the
code, I'm guessing that both the Linux and Solaris ACL tools wanted a
quick way to test whether an ACE had one of those special owners without
doing a strcmp(), so defined these extra bits in the flag field.  Which
seems like a premature optimization to me, but, whatever.

The only use of those constants is probably internal to the ACL tools,
so they don't have to agree with any standards.

But that's just a guess, check the code to be sure.

--b.

> 
> I'm currently working on implementing support for the native NFSv4
> ACL in the ZFS on Linux port, using nfs4-acl-tools as the mechanism
> for viewing and updating them. I noticed a discrepancy between the
> definitions in the ZFS NFSv4 ACL include file versus the ones in the
> nfs4-acl-tools headers.
> 
> Specifically, in zfs:
> 
> #define ACE_INHERITED_ACE               0x0080
> #define ACE_OWNER                       0x1000
> #define ACE_GROUP                       0x2000
> #define ACE_EVERYONE                    0x4000
> 
> Whereas in nfs4-acl-tools:
> 
> #define NFS4_ACE_OWNER                        0x00000080
> #define NFS4_ACE_GROUP                        0x00000100
> #define NFS4_ACE_EVERYONE                     0x00000200
> 
> I'm not sure where these values came from, I don't see them in the
> NFSv4 RFC. Do you happen to have any idea where the values used in
> the nfs4-acl-tools came from and why they might be different than
> those used by zfs?
> 
> Thanks much…
