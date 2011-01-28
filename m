Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54178 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594Ab1A1Spt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jan 2011 13:45:49 -0500
Subject: Re: [PATCH 2/2] NFS: NFSv4 readdir loses entries
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
In-Reply-To: <4D430DFA.90708@netapp.com>
References: <20110128173624.3235.74504.stgit@matisse.1015granger.net>
	 <20110128174105.3235.21014.stgit@matisse.1015granger.net>
	 <4D430DFA.90708@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 28 Jan 2011 13:45:48 -0500
Message-ID: <1296240348.5464.20.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-01-28 at 13:42 -0500, Bryan Schumaker wrote: 
> On 01/28/2011 12:41 PM, Chuck Lever wrote:
> > On recent 2.6.38-rc kernels, connectathon basic test 6 fails on
> > NFSv4 mounts of OpenSolaris with something like:
> > 
> >> ./test6: readdir
> >> 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.12' dir entry, pass 0
> >> 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.82' dir entry, pass 0
> >> 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.164' dir entry, pass 0
> >> 	./test6: (/mnt/klimt/matisse.test) Test failed with 3 errors
> >> basic tests failed
> >> Tests failed, leaving /mnt/klimt mounted
> >> [cel@matisse cthon04]$
> > 
> > I narrowed the problem down to nfs4_decode_direct() reporting that the
> 
> I'm guessing that should be nfs4_decode_dirent()?

I've fixed that up in the version I applied to the 'bugfixes' branch.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

