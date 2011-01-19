Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:58300 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754066Ab1ASO14 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jan 2011 09:27:56 -0500
Date: Wed, 19 Jan 2011 09:27:52 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Daniel.Muntz@emc.com, matt@linuxbox.com, androsadamson@gmail.com,
        linux-nfs@vger.kernel.org, bhalevy@panasas.com
Subject: Re: 4.1 no-pnfs mount option?
Message-ID: <20110119142752.GB6026@merit.edu>
References: <DE966DA98A4ABE438D726BDF1699CF61043985B644@MX05A.corp.emc.com>
 <1295405796.2919.2.camel@heimdal.trondhjem.org>
 <DE966DA98A4ABE438D726BDF1699CF61043985B65A@MX05A.corp.emc.com>
 <1295445912.3444.10.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1295445912.3444.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Have we beaten this dead horse to a pulp yet?  I was just asking if there
was such an option, not advocating for adding one.  It would have been
useful at the time for my own testing but I can see the argument against
adding unwanted knobs.

The discussion has been useful in one way.  I will now be spending some time
making sure the block layout driver falls back gracefully to no-pnfs if, for
example, an iscsi target can't be contacted.
