Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ozlabs.org ([203.10.76.45]:53877 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933013Ab2JDA0N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Oct 2012 20:26:13 -0400
Date: Thu, 4 Oct 2012 10:26:01 +1000
From: Anton Blanchard <anton@samba.org>
To: Alexander Graf <agraf@suse.de>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, skinsbursky@parallels.com,
        bfields@redhat.com, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: Re: [REGRESSION] nfsd crashing with 3.6.0-rc7 on PowerPC
Message-ID: <20121004102601.52790b04@kryten>
In-Reply-To: <E141CA01-F58C-47B1-8ED5-A314D1DEC968@suse.de>
References: <3BDA9E62-7031-42D6-8CA9-5327B61700F5@suse.de>
	<CA+55aFyXwB1QcXE4Z_FAGnXROSgvP2x2+wjnX9OWPa4Dfaaf0A@mail.gmail.com>
	<DC545CD9-8745-47DD-B13B-3385C0EB5B27@suse.de>
	<20120928151043.GA19102@fieldses.org>
	<2A52FC96-148C-4F7A-9950-E152E0C6698D@suse.de>
	<1349139509.3847.2.camel@pasglop>
	<20121002214327.GA29218@linux.vnet.ibm.com>
	<9257E705-4EF9-4347-945C-B4A7582C427F@suse.de>
	<20121002221736.GB29218@linux.vnet.ibm.com>
	<E141CA01-F58C-47B1-8ED5-A314D1DEC968@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

> Yes. With that patch applied, things work for me again.

Thanks Alex, Nish. We can reproduce this on one of our Biminis, looking
into it now.

Anton
