Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:57278 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755595Ab2ENLmS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2012 07:42:18 -0400
Message-ID: <4FB0EF6A.3080404@panasas.com>
Date: Mon, 14 May 2012 14:41:30 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Lior <lior@tonian.com>
CC: <tigran.mkrtchyan@desy.de>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: nfs v4.1 client without pNFS
References: <4FAF9E19.4060802@tonian.com> <CAGue13rFG30EzmQX7sfYA_ouPBxaUu1Xs8sb1ee4fBMtaufKpA@mail.gmail.com> <4FAFBD04.8020301@tonian.com> <4FB0CF8C.8090405@panasas.com> <4FB0ECBE.2060503@tonian.com>
In-Reply-To: <4FB0ECBE.2060503@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/14/2012 02:30 PM, Lior wrote:

> I don't think you can export the same FS ( same path ) twice in 2 
> different ways...


Look into bind mounts. 

In lots of admin schools they teach you that you actually export an
alias of a path at /export and not expose the real path on Server.
So you can change in the future with out changing Clients fstabs or
scripts.

Cheers
Boaz

