Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50772 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346Ab3JAOaw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 10:30:52 -0400
Date: Tue, 1 Oct 2013 10:30:51 -0400
From: "'Bruce Fields'" <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Kernel NFS List'" <linux-nfs@vger.kernel.org>,
        "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>
Subject: Re: pynfs updates
Message-ID: <20131001143051.GH26382@fieldses.org>
References: <003301cebe09$5bf81090$13e831b0$@mindspring.com>
 <20130930221126.GD26382@fieldses.org>
 <003f01cebe38$75436480$5fca2d80$@mindspring.com>
 <20131001142601.GG26382@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131001142601.GG26382@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One more problem: CSID10 is failing against the Linux server with
NFS4ERR_TOO_MANY_OPS, because each of those lookups is actually a full
lookup from PUTROOTFH to /, resulting in 17 ops on my setup.  Could we
maybe work relative to the parent directory instead?

--b.
