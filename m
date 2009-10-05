Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:46780 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066AbZJEQpM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2009 12:45:12 -0400
Received: by pxi9 with SMTP id 9so3134429pxi.4
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2009 09:44:34 -0700 (PDT)
In-Reply-To: <200910051831.56157.agruen@suse.de>
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com>
	 <20090902202206.GJ17884@fieldses.org>
	 <200910051831.56157.agruen@suse.de>
Date: Mon, 5 Oct 2009 11:44:34 -0500
Message-ID: <524f69650910050944k9bd0a3ci7b728f13b2c8225b@mail.gmail.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
From: Steve French <smfrench@gmail.com>
To: Andreas Gruenbacher <agruen@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        ffilzlnx@linux.vnet.ibm.com, linux-nfs@vger.kernel.org,
        nfsv4@linux-nfs.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        jra@samba.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Oct 5, 2009 at 11:31 AM, Andreas Gruenbacher <agruen@suse.de> wrote:
> On Wednesday 02 September 2009 22:22:06 J. Bruce Fields wrote:
>> On Wed, Sep 02, 2009 at 01:56:23PM -0500, Steve French wrote:
>> > In the meantime we don't even have a generalized system interface to
>> > set/get nfsv4/cifs/ntfs acls
>>
>> The current client is using raw xdr-formatted v4 acls in an extended
>> attribute.  We could consider some other interface if that would be more
>> useful to other projects.  (Andreas' patches have a different
>> xattr-based interface which might serve as another example.)
>
> Yes, the current nfsv4 client exposes NFSv4 ACLs with "user@domain" and
> "group@domain" identifiers in xattrs. Users and groups of local processes and
> files are are identified by ID though, so the kernel would have to map between
> "user@domain" and "group@domain" identifiers and IDs even for local accesses.
> This doesn't make sense. The native NSFv4 ACL prototype [1] uses IDs in its
> xattr format instead; all the ID mapping logic remains in NFSv4 (and in Samba
> for CIFS).
>
> [1] http://www.suse.de/~agruen/nfs4acl/

Recently I looked through NFSv4.1 spec, and it seems to address some
ACL incompatibilities (with CIFS) by extending the NFSv4 ACL model.

Should we be aiming for an eventual interface that would work for NFSv4.1
or limiting it to current NFSv4?

Any idea on the state of NFSv4.1 it seems to be stuck for almost a year?


-- 
Thanks,

Steve
