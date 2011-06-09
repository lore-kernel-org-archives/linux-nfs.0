Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36482 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756180Ab1FILef (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2011 07:34:35 -0400
Date: Thu, 9 Jun 2011 07:34:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Vladimir Elisseev <vovan@vovan.nl>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS3 + kerberos: performance issues
Message-ID: <20110609113433.GA9110@fieldses.org>
References: <1307086159.1052.19.camel@vovan.net.home>
 <1307104354.2477.17.camel@lade.trondhjem.org>
 <1307123836.1052.23.camel@vovan.net.home>
 <20110607230754.GF13911@fieldses.org>
 <1307514377.1533.35.camel@vovan.net.home>
 <20110608153950.GB4101@fieldses.org>
 <1307548836.1533.46.camel@vovan.net.home>
 <20110608162449.GD4101@fieldses.org>
 <1307595735.1533.62.camel@vovan.net.home>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1307595735.1533.62.camel@vovan.net.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 09, 2011 at 07:02:15AM +0200, Vladimir Elisseev wrote:
> This morning I've decided to redo all the tests and include some more
> statistics ( mountstat and vmstat ). However, when I exported the same
> mount point with different options I missed one _very_ important option.
> This option was presented for the export with sec=sys, but omitted with
> sec=krb5. The option is "async"... I promise to be more careful before
> posting any results.

Yep, that would explain it--thanks for letting us know.

--b.
