Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm12-vm0.access.bullet.mail.mud.yahoo.com ([66.94.236.11]:32492
	"HELO nm12-vm0.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754856Ab1ILVeL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 17:34:11 -0400
Message-ID: <4E6E7ACC.8040003@schaufler-ca.com>
Date: Mon, 12 Sep 2011 14:34:04 -0700
From: Casey Schaufler <casey@schaufler-ca.com>
To: Valdis.Kletnieks@vt.edu
CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, agruen@kernel.org,
        bfields@fieldses.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        LSM <linux-security-module@vger.kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH -V6 00/26] New ACL format for better NFSv4 acl interoperability
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>            <4E655049.6060507@schaufler-ca.com> <108028.1315442771@turing-police.cc.vt.edu>
In-Reply-To: <108028.1315442771@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 9/7/2011 5:46 PM, Valdis.Kletnieks@vt.edu wrote:
> On Mon, 05 Sep 2011 15:42:17 PDT, Casey Schaufler said:
>> On 9/5/2011 10:25 AM, Aneesh Kumar K.V wrote:
>>> The following set of patches implements VFS and ext4 changes needed to implement
>>> a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
>>> extended by file( masks to fit into the standard POSIX file permission model.
>>> They are designed to work seamlessly locally as well as across the NFSv4 and
>>> CIFS/SMB2 network file system protocols.
>>
>> POSIX ACLs predate the LSM and can't be done as an LSM due to
>> the interactions between mode bits and ACLs as defined by the
>> POSIX DRAFT specification. Is there a reason that "rich" ACLs
>> can not be done as an LSM?
>
> Well, if it was done as an LSM, it would mean that if I wanted to build a
> system where I have a few hundred terabytes of disk exported via Samba, and I
> wanted Samba to save the CIFS permission ACL, I couldn't also run Selinux or
> SMACK or anything like that - unless somebody actually snuck in the "LSMs are
> stackable" patch while I wasn't looking?
>
 
True, but not an acceptable argument for not doing it as an LSM.
It is an argument in favor of LSM stacking, and after the Linux
Security Summit this past week it seems only a matter of time before
we have that. This could be the compelling use case that we've been
missing for LSM stacking.
 
So at this point, unless there is another reason why it can't be an
LSM it should be an LSM.
 

