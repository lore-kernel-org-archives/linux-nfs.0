Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:63954 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750877AbcAUThY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jan 2016 14:37:24 -0500
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <dros@primarydata.com>
Subject: Re: [PATCH v2 3/3] nfsd: implement machine credential support for some operations
References: <1453147702-42961-1-git-send-email-aweits@rit.edu>
	<1453147702-42961-4-git-send-email-aweits@rit.edu>
	<20160121190134.GB1793@fieldses.org>
Date: Thu, 21 Jan 2016 14:30:42 -0500
In-Reply-To: <20160121190134.GB1793@fieldses.org> (J. Bruce Fields's message
	of "Thu, 21 Jan 2016 14:01:34 -0500")
Message-ID: <m237tqpw65.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Doesn't this mean that a compound like e.g.:
>
> 	PUTFH
> 	CLOSE
> 	OPEN
>
> would result in a return of true on the OPEN, if CLOSE was in must_allow
> but OPEN wasn't?  (Because the above loop sets spo_must_allowed as soon
> as it hits the CLOSE.)

Yes. A real-world example is DELEGRETURN with the Linux NFS client:

PUTFH
GETATTR
DELEGRETURN

GETATTR isn't in spo_must_allowed, but the whole compound request looks like
krb5i in a krb5 setting. Still digesting the rest of your replies...

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
