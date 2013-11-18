Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:39957 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778Ab3KRSlW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Nov 2013 13:41:22 -0500
Message-ID: <528A5F4F.4050201@netapp.com>
Date: Mon, 18 Nov 2013 13:41:19 -0500
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix kbuild errors due to missing symbols
References: <1384554636-25330-1-git-send-email-bjschuma@netapp.com> <1384557410.3222.2.camel@leira.trondhjem.org> <528A5360.4000206@netapp.com> <3D379D5B-C02D-4AAD-9A21-08A70BA3AF48@netapp.com>
In-Reply-To: <3D379D5B-C02D-4AAD-9A21-08A70BA3AF48@netapp.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/18/2013 01:37 PM, Myklebust, Trond wrote:
> 
> On Nov 18, 2013, at 12:50, Anna Schumaker <bjschuma@netapp.com> wrote:
>>
>> It's a poorly phrased commit message, actually.  I meant that just setting CONFIG_NFS_USE_LEGACY_DNS=y causes build problems, and then setting CONFIG_NFS_V4=n causes a different set of errors.
> 
> Ah. OK, now I see why you need it. The code in fs/nfs/super.c relies on it when !defined CONFIG_NFS_V4.
> 
> You also need to move the CONFIG_NFS_V4_SECURITY_LABEL section outside the CONFIG_NFS_V4, since fs/nfs/dir.c and others need the dummy nfs4_label_alloc and nfs4_label_free inline functions (see Stephen Rothwell
> ’s email).

Right.  I have a patch that moves them to internal.h instead to get around the whole-file #ifdef that's in nfs4_fs.h.  Would you prefer me to submit that independently or as a v2 to this patch?

As a bonus, I've used Jenkins to compile as many combinations as possible without an error (I probably should have done that the first time, though...)

Anna

> 
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

