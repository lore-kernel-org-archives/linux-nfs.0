Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:11667 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750925AbcAVABd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jan 2016 19:01:33 -0500
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <dros@primarydata.com>
Subject: Re: [PATCH v2 3/3] nfsd: implement machine credential support for some operations
References: <1453147702-42961-1-git-send-email-aweits@rit.edu>
	<1453147702-42961-4-git-send-email-aweits@rit.edu>
	<20160121190134.GB1793@fieldses.org>
	<m237tqpw65.fsf@discipline.rit.edu>
	<20160121195003.GD1793@fieldses.org>
Date: Thu, 21 Jan 2016 19:01:31 -0500
In-Reply-To: <20160121195003.GD1793@fieldses.org> (J. Bruce Fields's message
	of "Thu, 21 Jan 2016 14:50:03 -0500")
Message-ID: <m2si1qmqhw.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Ugh.  So the client actually needs to allow random other ops in any
> compound containing an spo_must_allow'd operation?  That doesn't seem
> right to me.

Well, that's most certainly my fault. Seems like I should
submit a patch to have the client ask for GETATTR if it's going to send
it as a tag-along to DELEGRETURN. Is WRONGSEC really the correct way
to enforce appropriate use of spo_must_allow here?

For instance, the client could ask for just DELEGRETURN:

PUTFH
GETATTR
DELEGRETURN

...would be successful as long as the export was done with krb5i/krb5p.

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
