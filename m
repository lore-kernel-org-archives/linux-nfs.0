From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 17:25:18 -0400
Message-ID: <1250889918.5700.12.camel@heimdal.trondhjem.org>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org>
	 <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com>
	 <20090821182418.GE21043@fieldses.org>
	 <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
	 <20090821200403.GA23529@fieldses.org>
	 <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com>
	 <1250889345.5700.11.camel@heimdal.trondhjem.org> <4A8F0FCC.2080709@sun.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <Chuck.Lever@oracle.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13099 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932731AbZHUVZR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 17:25:17 -0400
In-Reply-To: <4A8F0FCC.2080709-xsfywfwIY+M@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 16:21 -0500, Tom Haynes wrote:
> The Linux client and server have well defined behaviors in that they always
> will default to AUTH_SYS.
> 
> It may not be standard compliant, but everyone and their dog knows it.
> 
> Newer servers will not hand out empty lists, and why cause yourself grief
> by not handling older servers?

Particularly so when we used to handle those older servers well.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
