From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 12:58:12 -0400
Message-ID: <1251219492.25372.3.camel@heimdal.trondhjem.org>
References: <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
	 <20090821200403.GA23529@fieldses.org>
	 <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com>
	 <1250889345.5700.11.camel@heimdal.trondhjem.org>
	 <20090821213016.GG23529@fieldses.org>
	 <1250890836.5700.19.camel@heimdal.trondhjem.org>
	 <20090821214720.GH23529@fieldses.org>
	 <1250891463.5700.21.camel@heimdal.trondhjem.org>
	 <20090824161004.GB4985@fieldses.org>
	 <1251133618.6325.262.camel@heimdal.trondhjem.org>
	 <20090824174129.GD4985@fieldses.org>
	 <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com>  <4A94162C.20904@sun.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <Chuck.Lever@oracle.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821AbZHYQ6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 12:58:11 -0400
In-Reply-To: <4A94162C.20904-xsfywfwIY+M@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-25 at 11:49 -0500, Tom Haynes wrote:
> With OpenSolaris NFSv3, there is no autonegotiation.  With NFSv4, we 
> support the autonegotiation
> as defined in the protocol.
> 
> We just went through a regression with this algorithm.

NFSv4 also allows the server to change the list of supported security
flavours on the fly at any point in the namespace, and at any time. How
does OpenSolaris currently deal with this?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
