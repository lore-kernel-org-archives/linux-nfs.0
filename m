From: Andi Kleen <andi@firstfloor.org>
Subject: Re: ->migratepage aops for nfs missing
Date: Wed, 5 Aug 2009 09:30:36 +0200
Message-ID: <20090805073036.GC11385@basil.fritz.box>
References: <1249419186.5377.20.camel@heimdal.trondhjem.org> <20090804202648.GA12484@basil.fritz.box> <25558.1249423367@redhat.com> <1249423594.12510.0.camel@heimdal.trondhjem.org> <1249430567.12510.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>,
	Andi Kleen <andi@firstfloor.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49210 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933642AbZHEHaj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 03:30:39 -0400
In-Reply-To: <1249430567.12510.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Make NFS a bit more NUMA-friendly...

Minor nit :- page migration is not only used for NUMA.

-Andi
