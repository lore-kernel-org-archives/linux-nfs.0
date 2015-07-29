Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:40854 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753102AbbG2TwG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jul 2015 15:52:06 -0400
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        "Anna Schumaker" <schumakeranna@gmail.com>
Subject: Re: list_del corruption / unhash_ol_stateid()
References: <m23809zl8z.fsf@discipline.rit.edu>
	<m2zj2hwk4e.fsf@discipline.rit.edu>
	<20150728090206.1331e476@tlielax.poochiereds.net>
	<m2wpxktjfc.fsf@discipline.rit.edu>
	<20150728114933.6f917374@tlielax.poochiereds.net>
	<20150728210434.GC9349@fieldses.org>
	<m24mknq9ga.fsf@discipline.rit.edu>
Date: Wed, 29 Jul 2015 15:52:04 -0400
In-Reply-To: <m24mknq9ga.fsf@discipline.rit.edu> (Andrew W. Elble's message of
	"Wed, 29 Jul 2015 11:17:57 -0400")
Message-ID: <m28u9yoi6z.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> I started with this - not completely sure this covers all the cases
> we're interested in.

Oops. Apparently I like to take lots of extra refs on files. Will redo this tomorrow.

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
