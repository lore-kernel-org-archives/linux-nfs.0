Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:11856 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753996AbcAVQJQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2016 11:09:16 -0500
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <dros@primarydata.com>
Subject: Re: [PATCH v2 3/3] nfsd: implement machine credential support for some operations
References: <1453147702-42961-1-git-send-email-aweits@rit.edu>
	<1453147702-42961-4-git-send-email-aweits@rit.edu>
	<20160122154045.GB9082@fieldses.org>
Date: Fri, 22 Jan 2016 11:09:15 -0500
In-Reply-To: <20160122154045.GB9082@fieldses.org> (J. Bruce Fields's message
	of "Fri, 22 Jan 2016 10:40:45 -0500")
Message-ID: <m27fj1lhp0.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> By the way, is the only problem is that the client is trying to do
> krb5i/krb5p on an export exported only with sec=sys or sec=krb5?

Barring anything else I missed, yes.

> So for example we could allow krb5i/krb5p on any compound containing an
> so_must_allow op?

This was roughly my reasoning/question...

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
