Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:41645 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752198Ab3CUChg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 22:37:36 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Rick Macklem <rmacklem@uoguelph.ca>
CC: Christopher T Vogan <cvogan@us.ibm.com>, Neil Brown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Haynes, Tom" <Tom.Haynes@netapp.com>, nfsv4 list <nfsv4@ietf.org>
Subject: Re: [nfsv4] What is NFSv4 READDIR doesn't return a filehandle....
Date: Thu, 21 Mar 2013 02:37:35 +0000
Message-ID: <1363833453.4790.123.camel@leira.trondhjem.org>
References: <1533754809.4129999.1363830100661.JavaMail.root@erie.cs.uoguelph.ca>
	 <1363831497.4790.114.camel@leira.trondhjem.org>
In-Reply-To: <1363831497.4790.114.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-03-21 at 02:04 +0000, Myklebust, Trond wrote:
> Implementations are only relevant here in as far as they limit the
> protocol changes that RFC3530bis can make. Given that there are clients
> out there that assume a strict interpretation of RFC3530, then it is too
> late to have RFC3530bis relax that interpretation.

To put it differently: if you disagree, then please point to the text in
RFC3530, or RFC5661 (or RFC3530bis at this point) that supports your
position that Mandatory/REQUIRED attributes such as "filehandle" may be
ignored by a server in READDIR requests.
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
