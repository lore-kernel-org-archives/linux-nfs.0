From: "young dave" <hidave.darkstar@gmail.com>
Subject: Re: [NFS] [PATCH] NFSD: fix uninitialized variable
Date: Tue, 29 May 2007 04:31:12 +0000
Message-ID: <a8e1da0705282131w72fbed65g8cb28589202298c1@mail.gmail.com>
References: <20070527103442.GA10594@havoc.gtf.org>
	 <20070529030050.GB20631@fieldses.org> <465B9BB9.7060300@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Andrew Morton" <akpm@linux-foundation.org>, neilb@suse.de,
	nfs@lists.sourceforge.net, LKML <linux-kernel@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763053AbXE2EbX@vger.kernel.org>
In-Reply-To: <465B9BB9.7060300@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

> Given what you said above, I don't see gcc, on its best day, will ever
> know enough to validate that that variable is indeed always initialized.
>   So I would vote for silencing it on those grounds.

I agree too. How about this one:

diff -dur linux/fs/nfsd/nfs4acl.c linux.new/fs/nfsd/nfs4acl.c
--- linux/fs/nfsd/nfs4acl.c     2007-05-29 12:28:29.000000000 +0000
+++ linux.new/fs/nfsd/nfs4acl.c 2007-05-29 12:30:45.000000000 +0000
@@ -183,8 +183,6 @@
 summarize_posix_acl(struct posix_acl *acl, struct posix_acl_summary *pas)
 {
        struct posix_acl_entry *pa, *pe;
-       pas->users = 0;
-       pas->groups = 0;
        pas->mask = 07;

        pe = acl->a_entries + acl->a_count;
@@ -229,6 +227,7 @@
        int eflag = ((flags & NFS4_ACL_TYPE_DEFAULT) ?
                NFS4_INHERITANCE_FLAGS | NFS4_ACE_INHERIT_ONLY_ACE : 0);

+       memset(pas, 0, sizeof(struct posix_acl_summary);
        BUG_ON(pacl->a_count < 3);
        summarize_posix_acl(pacl, &pas);

Regards
dave
