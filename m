Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:49258 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbZHZQMq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 12:12:46 -0400
Received: by fxm17 with SMTP id 17so246717fxm.37
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2009 09:12:47 -0700 (PDT)
In-Reply-To: <551A5C21-FB0F-4B77-B817-80A368A0F054@oracle.com>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <d4098e2f0908250901y359e51cewb1e22e7193922c52@mail.gmail.com>
	 <1251226809.25372.29.camel@heimdal.trondhjem.org>
	 <d4098e2f0908251206o34590902u9a69aed32142d67e@mail.gmail.com>
	 <1251227539.25372.35.camel@heimdal.trondhjem.org>
	 <d4098e2f0908251219w42340c9ak4538a22f8d7391b6@mail.gmail.com>
	 <1251228350.25372.36.camel@heimdal.trondhjem.org>
	 <5FC6E83A-4D26-4A77-B3F0-E34A9E97E9B5@oracle.com>
	 <d4098e2f0908251245y4ed4a93bycf1a8cf902b18d84@mail.gmail.com>
	 <551A5C21-FB0F-4B77-B817-80A368A0F054@oracle.com>
Date: Wed, 26 Aug 2009 18:12:47 +0200
Message-ID: <d4098e2f0908260912g6d62e7a4w1da3268704d832a5@mail.gmail.com>
Subject: Re: NFS v3 cached directory content out of sync
From: Stefan Egli <stefan.egli@gmail.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

FYI: For the reference a quick summary of this issue:

Linux Kernels older than 2.6.30 (or at least in 2.6.26 which we're
using) have this bug which can be reproduced as follows:

 * have two hosts: host A and host B - both having the same NFS
directory mounted and being in the same subdirectory on that NFS

 * host A: mkdir testdir; touch -m --date "2009-08-25 11:35" testdir
 * host B: ls testdir
 * host A: touch testdir/aNewFile; touch -m --date "2009-08-25 11:35" testdir
 * host B: ls testdir
   * shows an empty directory - even though 'aNewFile' just got
created. This remains so for hours.

The commit-set ID which is probably related (as of now I couldn't test
the above on 2.6.30):

37d9d76d8b3a2ac5817e1fa3263cfe0fdb439e51

Cheers,
Stefan
