From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Thu, 12 Feb 2009 17:03:48 -0500
Message-ID: <1234476228.7190.188.camel@heimdal.trondhjem.org>
References: <20090211112318.GA29133@janus>
	 <20090211203555.GC27686@fieldses.org> <20090211203703.GA9662@janus>
	 <20090211203948.GD27686@fieldses.org> <20090212142830.GA28107@janus>
	 <1234451789.7190.38.camel@heimdal.trondhjem.org>
	 <20090212153634.GB28107@janus>
	 <1234462647.7190.53.camel@heimdal.trondhjem.org>
	 <20090212182943.GA1945@janus>
	 <1234465837.7190.62.camel@heimdal.trondhjem.org>
	 <03CEE6BB-D39D-47A5-BB6C-2FB3E206142F@oracle.com>
	 <1234467795.7190.70.camel@heimdal.trondhjem.org>
	 <D4DD97F7-B10B-43B5-B8F9-B7A489355A5E@oracle.com>
	 <1234470457.7190.106.camel@heimdal.trondhjem.org>
	 <2171ACCA-5CF5-425D-B7A4-CFB17DA61F75@oracle.com>
	 <1234472083.7190.124.camel@heimdal.trondhjem.org>
	 <A05823EC-E711-47EF-BFAA-6EE87A6B7DEF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:44623 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754932AbZBLWDz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2009 17:03:55 -0500
In-Reply-To: <A05823EC-E711-47EF-BFAA-6EE87A6B7DEF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-02-12 at 16:43 -0500, Chuck Lever wrote:
> Having nlm_cmp_addr() do the mapping solves some problems, but at the  
> cost of extra CPU time every time it is called; each loop iteration in  
> nlm_lookup_host() for example.  All I'm doing is removing a loop  
> invariant, essentially.

nlm_lookup_host() shouldn't need to compare v4 mapped addresses and IPv4
addresses afaics.


