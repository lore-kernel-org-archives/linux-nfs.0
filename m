From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 19:23:11 -0500
Message-ID: <1231287791.11487.4.camel@heimdal.trondhjem.org>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com>
	 <1231274682.20316.65.camel@heimdal.trondhjem.org>
	 <20090106215831.GE18147@us.ibm.com>
	 <1231281732.4173.6.camel@heimdal.trondhjem.org>
	 <1231286930.14345.196.camel@localhost>
	 <20090107002024.GJ13785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Matt Helsley <matthltc@us.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62309 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438AbZAGAXa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 19:23:30 -0500
In-Reply-To: <20090107002024.GJ13785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 19:20 -0500, J. Bruce Fields wrote:
> If it would be possible, for example, for the 'init' namespace to have
> no network interfaces at all, then it would be nicer to use a name
> that's at least been used with nfs at *some* point--just on the general
> principle of not leaking information to a domain that the user wouldn't
> expect it to.

Then RPC would fail. Thanks to the limitations imposed by selinux &
friends, all RPC sockets have to be owned by the init process.
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
