Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33246 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375AbbEMVPu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2015 17:15:50 -0400
MIME-Version: 1.0
In-Reply-To: <20150513205531.GG10059@samba2>
References: <cover.1429868795.git.agruenba@redhat.com>
	<28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
	<0b2401d08da6$dad0d0f0$907272d0$@mindspring.com>
	<CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>
	<20150513202803.GD10059@samba2>
	<CAHpGcMLg2+SrMJrFe9Sj-tfXVMW040xJMq2uRcAM+LBEUmqpvA@mail.gmail.com>
	<20150513205531.GG10059@samba2>
Date: Wed, 13 May 2015 23:15:50 +0200
Message-ID: <CAHpGcMJw92aF9yyXOYhe9W+hoj3oJS_dZ_wMBfaT7JL4iWKrPg@mail.gmail.com>
Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Jeremy Allison <jra@samba.org>
Cc: Frank Filz <ffilzlnx@mindspring.com>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-13 22:55 GMT+02:00 Jeremy Allison <jra@samba.org>:
> Hmm. Just realized we may be talking about different things :-).
>
> In SMB/Samba the clients can create a file with no ACL, and
> the directory ACL is auto inherited. *That* we fake in
> Samba by creating then updating.

Yes, that's what I was trying to say in the commit message of this
patch. Samba will have to continue doing that.

> But in Windows there are the concept of "inherited" ACE
> entries, which can come from parents of parents of parents
> (etc.) objects.

Fair enough, even if from the child's point of view, all inherited
entries come from the direct parent no matter where the parent
has gotten them from.

> When a client modifies one of these on an
> upper level directory, the server doesn't do the auto
> updating that the vision of the file system might lead
> you to expect - that updating is done by a tree walk
> by the client.

Good, then we're on the same page.

Thanks,
Andreas
