Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:18451 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753993AbbHXTyU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 15:54:20 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: <bfields@fieldses.org>, Anna Schumaker <Anna.Schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/2] nfsd: fix unhashing races in nfsv4 stateid handling
References: <1440434508-16046-1-git-send-email-jeff.layton@primarydata.com>
Date: Mon, 24 Aug 2015 15:54:19 -0400
In-Reply-To: <1440434508-16046-1-git-send-email-jeff.layton@primarydata.com>
	(Jeff Layton's message of "Mon, 24 Aug 2015 12:41:46 -0400")
Message-ID: <m2vbc47990.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@poochiereds.net> writes:

> v2:
> - fix the fault injection code to handle the prototype change to
>   unhash_lock_stateid

Jeff,

   We're running with this in place now. It definitely covers the same
  bases my quick hack was covering, so I don't foresee any issues with
  it - But I'll give a definitive answer tomorrow.

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
