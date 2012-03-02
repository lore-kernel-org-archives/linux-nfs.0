Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:50854 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645Ab2CBWwS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 17:52:18 -0500
Message-ID: <4F514F16.6050307@panasas.com>
Date: Fri, 2 Mar 2012 14:52:06 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Benny Halevy <bhalevy@panasas.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 15/15] NFS: Fix some minor problems with nfs4_deviceids
References: <20120301215755.2138.73488.stgit@degas.1015granger.net> <20120301220222.2138.65095.stgit@degas.1015granger.net> <1330641595.15828.16.camel@lade.trondhjem.org> <4D0F430A-73F2-4AAE-A087-302EE08D29C0@oracle.com> <EA56F79D-3608-443B-99DA-0D5E46C678B9@oracle.com> <4F51429B.1040106@panasas.com> <F46AE88D-FBBC-41E7-AAF8-754796EFD620@oracle.com> <4F514470.9050201@panasas.com> <938067E8-AD4F-49B1-B499-5146FBBB2AEC@oracle.com>
In-Reply-To: <938067E8-AD4F-49B1-B499-5146FBBB2AEC@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/02/2012 02:11 PM, Chuck Lever wrote:
> 
> I still need someone with OSD pNFS set up to test.  Can I send you a proposed patch?
> 

Yes that would be me. Sure, best is if you have a public git tree I can pull
but if not then patchset in the mail is also fine

I'll run a test and report, tell me when

Boaz

