Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:52037 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756683Ab2D0OTZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 10:19:25 -0400
Date: Fri, 27 Apr 2012 10:19:18 -0400
From: Jim Rees <rees@umich.edu>
To: Josh Boyer <jwboyer@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFSv4: Add modalias for "nfs4"
Message-ID: <20120427141918.GA15506@umich.edu>
References: <20120427131031.GA13189@zod.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120427131031.GA13189@zod.bos.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Josh Boyer wrote:

  When NFSv4 is configured, the support goes into the nfs.ko module.
  However, nfs-utils seems to pass "nfs4" as the fileststem type for
  NFSv4 mounts.

Weren't we going to change that to nfs and use nfsvers to select nfs4?
