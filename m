Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:33856 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbbEMUrq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2015 16:47:46 -0400
MIME-Version: 1.0
In-Reply-To: <20150513202803.GD10059@samba2>
References: <cover.1429868795.git.agruenba@redhat.com>
	<28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
	<0b2401d08da6$dad0d0f0$907272d0$@mindspring.com>
	<CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>
	<20150513202803.GD10059@samba2>
Date: Wed, 13 May 2015 22:47:44 +0200
Message-ID: <CAHpGcMLg2+SrMJrFe9Sj-tfXVMW040xJMq2uRcAM+LBEUmqpvA@mail.gmail.com>
Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Jeremy Allison <jra@samba.org>
Cc: Frank Filz <ffilzlnx@mindspring.com>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-13 22:28 GMT+02:00 Jeremy Allison <jra@samba.org>:
> On Wed, May 13, 2015 at 10:22:21PM +0200, Andreas Grünbacher wrote:
>>
>> That being said, a daemon like Samba can "fake" full Automatic
>> Inheritance by creating files and then updating the inherited acls
>> appropriately. This will inevitably be racy, but unless someone
>> implements a way to create files without a mode, that's the closest
>> Samba can get.
>
> On Windows systems the client fake (no quotes :-) full Automatic
> Inheritance by creating files and then updating the inherited acls
> appropriately.

Hmm, interesting, are you *absolutely* sure about that? Is there
anywhere I can look that up?

Thanks,
Andreas
