Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57152 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750978AbdLGXPG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Dec 2017 18:15:06 -0500
Date: Thu, 7 Dec 2017 18:15:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Drew Leske <drew.leske@computecanada.ca>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Non-root chown, NFSv4 ACLs
Message-ID: <20171207231506.GB7527@fieldses.org>
References: <DEC3CF38-E451-4E22-B904-DCD35188F000@computecanada.ca>
 <20171207213419.GA6147@fieldses.org>
 <F6FBCAE9-DB8D-4965-B761-58ACDF245BC3@computecanada.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <F6FBCAE9-DB8D-4965-B761-58ACDF245BC3@computecanada.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 07, 2017 at 02:54:22PM -0800, Drew Leske wrote:
> The remaining question for me then is around the NFSv4 ACL and the
> ownership change permission, and whether I should be able to get that
> to work, especially on a stock system.

No.  When you set an ACL, the server just translates that ACL to the
closet POSIX ACL it can find.  And the filesystem code just enforces
that POSIX ACL.  POSIX ACLs have no equivalent to WRITE_OWNER.  I can't
remember what the code in fs/nfsd/nfs4acl.c does--the only choices would
be to either ignore the bit or fail, I think it does the former.

(In theory knfsd could store the full v4 ACL in an extended attribute
and do its own enforcement on the side--I think Samba can do something
like this.  This seems complicated to me and I'd rather add richacl
support to the filesystems, but that effort has stalled.)

> I know there are some issues
> with mapping NFSv4 ACLs to so-called “POSIX” ACLs, but I didn’t see
> anything in the documentation to suggest it isn’t implemented.  Should
> I expect this to work without installing the richacls software?

You'd have to actually apply the richacls kernel patch.  I think you'd
find that more trouble than it's worth.

--b.
