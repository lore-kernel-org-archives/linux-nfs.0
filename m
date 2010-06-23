Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:45905 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470Ab0FWWvf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 18:51:35 -0400
Date: Thu, 24 Jun 2010 08:51:16 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
        Christoph Hellwig <hch@infradead.org>,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 3/8][RFC v05] NFSv3: add client implementation of XATTR
 protocol
In-Reply-To: <1277319497.4991.41.camel@heimdal.trondhjem.org>
Message-ID: <alpine.LRH.2.00.1006240836380.1601@tundra.namei.org>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>  <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org>  <4C1FC553.4030904@oracle.com>  <alpine.LRH.2.00.1006220906300.16648@tundra.namei.org>  <4C20D779.5040008@oracle.com>
 <alpine.LRH.2.00.1006230857450.25778@tundra.namei.org>  <20100623183542.GC28346@fieldses.org> <1277319497.4991.41.camel@heimdal.trondhjem.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 23 Jun 2010, Trond Myklebust wrote:

> Is there really much interest in adding NFSv4 support for xattrs beyond
> the security label use case?

I'm not sure -- I would imagine the rationale would be similar to the case 
for named attributes.  I'll see if I can find out more from desktop 
developers.


- James
-- 
James Morris
<jmorris@namei.org>
