Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:34662 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965383AbbEMVFp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2015 17:05:45 -0400
MIME-Version: 1.0
In-Reply-To: <0b2f01d08dbc$d3418940$79c49bc0$@mindspring.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
	<0b2401d08da6$dad0d0f0$907272d0$@mindspring.com>
	<CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>
	<0b2f01d08dbc$d3418940$79c49bc0$@mindspring.com>
Date: Wed, 13 May 2015 23:05:44 +0200
Message-ID: <CAHpGcM+t00=QjR5S+aoi_o=REdnTT7r_K0M7vh7fGESmtQP=_w@mail.gmail.com>
Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-13 22:38 GMT+02:00 Frank Filz <ffilzlnx@mindspring.com>:
> So inheritance will happen, but there is also a mode set as part of the create that I assume
> is effectively handled the same as a subsequent chmod() on the file?

The effect is similar to a subsequent chmod except that the effective
permissions may be fewer then the create mode:

 * In the traditional POSIX case, the effective permissions are
   (create_mode & ~umask).

 * With POSIX ACLs and Richacls, if there are inheritable permissions,
   the effective permissions are the intersection of the create mode and
   the maximum permissions the inherited acl grants. So if the inherited
   acl grants at most rwxr-x---, with a create mode of rw-rw-rw, the
   effective permissions end up being rw-r-----.

> Any chance we could add a system call to do a open/create and pass an ACL
> (and heck, if we go there, why not a system call that allows creating with mtime,
> atime, owner, etc. also...).

Send patches, but expect them to get killed :)

> Is there a mode that we could pass that would cause the least amount
> of damage to the inherited ACL?

Yes, 0777. But the RICHACL_PROTECTED flag will still be set, and that
is the problem in this case.

Andreas
