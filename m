Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:33471 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932417AbbEMUeo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 May 2015 16:34:44 -0400
Date: Wed, 13 May 2015 13:28:03 -0700
From: Jeremy Allison <jra@samba.org>
To: Andreas =?iso-8859-1?Q?Gr=FCnbacher?=
	<andreas.gruenbacher@gmail.com>
Cc: Frank Filz <ffilzlnx@mindspring.com>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
Message-ID: <20150513202803.GD10059@samba2>
Reply-To: Jeremy Allison <jra@samba.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
 <0b2401d08da6$dad0d0f0$907272d0$@mindspring.com>
 <CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 13, 2015 at 10:22:21PM +0200, Andreas Grünbacher wrote:
> 
> That being said, a daemon like Samba can "fake" full Automatic
> Inheritance by creating files and then updating the inherited acls
> appropriately. This will inevitably be racy, but unless someone
> implements a way to create files without a mode, that's the closest
> Samba can get.

On Windows systems the client fake (no quotes :-) full Automatic
Inheritance by creating files and then updating the inherited acls
appropriately.

Server doesn't do that logic :-).
