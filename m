Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:37543 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751086AbdLIAxM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Dec 2017 19:53:12 -0500
Received: by mail-pf0-f176.google.com with SMTP id n6so8428504pfa.4
        for <linux-nfs@vger.kernel.org>; Fri, 08 Dec 2017 16:53:12 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Non-root chown, NFSv4 ACLs
From: Drew Leske <drew.leske@computecanada.ca>
In-Reply-To: <20171207231506.GB7527@fieldses.org>
Date: Fri, 8 Dec 2017 16:53:09 -0800
Cc: linux-nfs@vger.kernel.org
Message-Id: <93573170-DAA6-4CC2-A017-44F4B10F3253@computecanada.ca>
References: <DEC3CF38-E451-4E22-B904-DCD35188F000@computecanada.ca> <20171207213419.GA6147@fieldses.org> <F6FBCAE9-DB8D-4965-B761-58ACDF245BC3@computecanada.ca> <20171207231506.GB7527@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> (In theory knfsd could store the full v4 ACL in an extended attribute
> and do its own enforcement on the side--I think Samba can do something
> like this.  This seems complicated to me and I'd rather add richacl
> support to the filesystems, but that effort has stalled.)


I=E2=80=99m sorry to hear that, I looked at the Git repository =
(https://github.com/andreas-gruenbacher/richacl) and it looked like =
things were slowing down, and the richacl site linked to here and there =
is 404.

Thanks very much for sharing your expertise.

Drew.

----
Drew Leske=20
Senior Software Developer
D=C3=A9veloppeur de logiciel principal

