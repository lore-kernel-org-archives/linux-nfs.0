Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12628 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756741Ab0I3RH1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 13:07:27 -0400
Subject: Re: [PATCH] nfs-utils: Add nfs.upcall for idmapper
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        SteveD@redhat.com
In-Reply-To: <59CA8CDE-0A68-4F99-BB09-804D24452148@oracle.com>
References: <4CA39681.3000104@netapp.com>
	 <1285798396.3557.18.camel@heimdal.trondhjem.org>
	 <4CA48CEF.9060600@netapp.com>
	 <59CA8CDE-0A68-4F99-BB09-804D24452148@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 30 Sep 2010 13:07:17 -0400
Message-ID: <1285866437.14635.27.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-09-30 at 11:42 -0400, Chuck Lever wrote:

> I might choose a less generic name for this program, unless there are plans to make it handle all NFS upcalls, eventually.  How about nfs.idmap ?

nfs.idmap sounds good.

> Should nfs.upcall have its own man page?  My opinion is that it should.  That might be a better place for the setup information (needed by mortal system administrators) added under Documentation/ by an earlier patch.  Documentation/ is an appropriate place for the upcall design information, though.

Agreed. We do need to help people who want to edit /etc/request-key.conf
themselves.

> Also, I've been looking at the Mesta-Adamson draft that provides NFSv4 domain information via DNS.  I'd like to see Linux make use of this TXT record, as Solaris does today.  It would help make Linux NFSv4 more automatically configurable, especially in heterogeneous environments.

That looks like something that needs to be added to libnfsidmap. I don't
think we need to make the kernel domain-aware.

> As I understand it, nfs.upcall would obviate rpc.idmapd, correct?  In that case, what entity would be responsible for a putative DNS lookup to determine the local NFSv4 domain name?  How would this information be cached?

See above.

> Finally, if at all possible, it would be better if the kernel could automatically recognize and use nfs.upcall rather than the legacy idmapping mechanism.  My experience with CONFIG options is that people will almost always choose the wrong setting no matter how many large neon arrows you add.  I know there are likely some technical challenges here.

I don't think that is easy to do. The keyring upcall mechanism will
almost always succeed, no matter whether or not there is a handler for
the type of key requested. Instead, it will result in a negative lookup.
Unfortunately, seeing a negative key isn't sufficient to determine that
no handler exists.

Cheers
  Trond
