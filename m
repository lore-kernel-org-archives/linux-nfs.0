Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:44635 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934426AbbEMW4H convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 May 2015 18:56:07 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "=?utf-8?Q?'Andreas_Gr=C3=BCnbacher'?="
	<andreas.gruenbacher@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <cover.1429868795.git.agruenba@redhat.com>	<28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>	<0b2401d08da6$dad0d0f0$907272d0$@mindspring.com>	<CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>	<0b2f01d08dbc$d3418940$79c49bc0$@mindspring.com> <CAHpGcM+t00=QjR5S+aoi_o=REdnTT7r_K0M7vh7fGESmtQP=_w@mail.gmail.com>
In-Reply-To: <CAHpGcM+t00=QjR5S+aoi_o=REdnTT7r_K0M7vh7fGESmtQP=_w@mail.gmail.com>
Subject: RE: [RFC v3 20/45] richacl: Automatic Inheritance
Date: Wed, 13 May 2015 15:56:04 -0700
Message-ID: <0b3401d08dcf$fe32c070$fa984150$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Andreas Grünbacher [mailto:andreas.gruenbacher@gmail.com]
> Sent: Wednesday, May 13, 2015 2:06 PM
> To: Frank Filz
> Cc: linux-kernel@vger.kernel.org; linux-fsdevel@vger.kernel.org; linux-
> nfs@vger.kernel.org
> Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
> 
> 2015-05-13 22:38 GMT+02:00 Frank Filz <ffilzlnx@mindspring.com>:
> > So inheritance will happen, but there is also a mode set as part of
> > the create that I assume is effectively handled the same as a subsequent
> chmod() on the file?
> 
> The effect is similar to a subsequent chmod except that the effective
> permissions may be fewer then the create mode:
> 
>  * In the traditional POSIX case, the effective permissions are
>    (create_mode & ~umask).
> 
>  * With POSIX ACLs and Richacls, if there are inheritable permissions,
>    the effective permissions are the intersection of the create mode and
>    the maximum permissions the inherited acl grants. So if the inherited
>    acl grants at most rwxr-x---, with a create mode of rw-rw-rw, the
>    effective permissions end up being rw-r-----.
> 
> > Any chance we could add a system call to do a open/create and pass an
> > ACL (and heck, if we go there, why not a system call that allows
> > creating with mtime, atime, owner, etc. also...).
> 
> Send patches, but expect them to get killed :)
> 
> > Is there a mode that we could pass that would cause the least amount
> > of damage to the inherited ACL?
> 
> Yes, 0777. But the RICHACL_PROTECTED flag will still be set, and that is the
> problem in this case.

I'm not clear what the RICHACL_PROTECTED flag actually does. It looks like it's only tested in chmod, and then only if the mode matches the mask (at least if I'm understanding the code right).

Frank

