Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:38940 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750983AbcGMTjx convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2016 15:39:53 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Andreas Gruenbacher'" <agruenba@redhat.com>
Cc: "'Jeff Layton'" <jlayton@redhat.com>,
        "'Alexander Viro'" <viro@zeniv.linux.org.uk>,
        "'Christoph Hellwig'" <hch@infradead.org>,
        "'Theodore Ts'o'" <tytso@mit.edu>,
        "'Andreas Dilger'" <adilger.kernel@dilger.ca>,
        "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>,
        "'Anna Schumaker'" <anna.schumaker@netapp.com>,
        "'Dave Chinner'" <david@fromorbit.com>,
        "'linux-ext4'" <linux-ext4@vger.kernel.org>,
        "'XFS Developers'" <xfs@oss.sgi.com>,
        "'LKML'" <linux-kernel@vger.kernel.org>,
        "'linux-fsdevel'" <linux-fsdevel@vger.kernel.org>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        <linux-cifs@vger.kernel.org>,
        "'Linux API'" <linux-api@vger.kernel.org>
References: <1467294433-3222-1-git-send-email-agruenba@redhat.com> <1467294433-3222-9-git-send-email-agruenba@redhat.com> <1467728537.3800.32.camel@redhat.com> <014101d1d6df$e059fd20$a10df760$@mindspring.com> <CAHc6FU5oeaCxgZPFeNSHDfSjnVKe9km14R4s5RoBhJXPaL7ymQ@mail.gmail.com>
In-Reply-To: <CAHc6FU5oeaCxgZPFeNSHDfSjnVKe9km14R4s5RoBhJXPaL7ymQ@mail.gmail.com>
Subject: RE: [PATCH v23 08/22] richacl: Compute maximum file masks from an acl
Date: Wed, 13 Jul 2016 12:38:50 -0700
Message-ID: <018b01d1dd3e$2f868170$8e938450$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > Hmm, but does that result in examining the whole ACL for most access
> checks, at least for files where most of the accesses are by the owner, or a
> member of a specific group (with perhaps a ton of special case users added
> on the end)?
> 
> I don't understand -- what does this algorithm have to do with access checks?

Oh, sorry, misread the patch... got caught up looking at a tree and not seeing the forest...

Frank



---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

