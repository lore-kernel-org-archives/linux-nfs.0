Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:46178 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752932AbdLMU2E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Dec 2017 15:28:04 -0500
Received: by mail-pf0-f181.google.com with SMTP id c204so1922141pfc.13
        for <linux-nfs@vger.kernel.org>; Wed, 13 Dec 2017 12:28:04 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Non-root chown, NFSv4 ACLs
From: Drew Leske <drew.leske@computecanada.ca>
In-Reply-To: <20171207231506.GB7527@fieldses.org>
Date: Wed, 13 Dec 2017 12:28:01 -0800
Cc: linux-nfs@vger.kernel.org
Message-Id: <A140722D-FE81-4E44-9ED0-1279E857B636@computecanada.ca>
References: <DEC3CF38-E451-4E22-B904-DCD35188F000@computecanada.ca> <20171207213419.GA6147@fieldses.org> <F6FBCAE9-DB8D-4965-B761-58ACDF245BC3@computecanada.ca> <20171207231506.GB7527@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> The remaining question for me then is around the NFSv4 ACL and the
>> ownership change permission, and whether I should be able to get that
>> to work, especially on a stock system.
>=20
> No.  When you set an ACL, the server just translates that ACL to the
> closet POSIX ACL it can find.  And the filesystem code just enforces
> that POSIX ACL.  POSIX ACLs have no equivalent to WRITE_OWNER.  I =
can't
> remember what the code in fs/nfsd/nfs4acl.c does--the only choices =
would
> be to either ignore the bit or fail, I think it does the former.

It does the former.  The POSIX ACL is stored in a short and the bit for =
NFS4_ACE_WRITE_OWNER is 0x80000, so it just drops off.

> (In theory knfsd could store the full v4 ACL in an extended attribute
> and do its own enforcement on the side--I think Samba can do something
> like this.  This seems complicated to me and I'd rather add richacl
> support to the filesystems, but that effort has stalled.)

It seems complicated and would split the POSIX ACL code from the NFSv4 =
ACL code, with little benefit for most people, with more risk due to the =
extra code to be maintained.  Given that all the translation code is =
already in place, I would be more inclined to leave it as is and maybe =
store, in addition and optionally, the untranslated NFSv4 ACL =
separately, so enforcement, which currently works, is left alone in the =
implementation and representation, which is lacking due to the =
retranslation back from POSIX ACL to NFSv4 ACL, can be switched on at =
the server if desired and passed back to the clients.  But I digress...

I've been looking at this over the last couple of days with the idea of =
storing the WRITE_OWNER permission as additional  extended attribute on =
the exported filesystem, initially as an array of UIDs/GIDs.  I think =
this should be workable: POSIX ACLs are stored as extended attributes =
and so this would be in addition to that.

Does this seem like a reasonable approach?

Would there be much interest in this, if implemented?

Cheers,
Drew.


Drew Leske
drew.leske@computecanada.ca



