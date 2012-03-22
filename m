Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:55971 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab2CVWRE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2012 18:17:04 -0400
Message-ID: <4F6BA4CA.8040308@panasas.com>
Date: Thu, 22 Mar 2012 15:16:42 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Change the default setting of the nfs4_disable_idmapping
 parameter
References: <1326138354-8138-1-git-send-email-Trond.Myklebust@netapp.com> <20120322204705.GA23737@fieldses.org> <1332449607.8976.9.camel@lade.trondhjem.org> <1332450074.8976.13.camel@lade.trondhjem.org> <20120322212616.GD23737@fieldses.org> <4F6BA3A2.1090501@panasas.com>
In-Reply-To: <4F6BA3A2.1090501@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/22/2012 03:11 PM, Boaz Harrosh wrote:
> I fail to see an opposite scenario where
> the brokenness was good, and now it will be bad.
> 

I might be wrong in this regard, Though. I'm not totally
on top of all the possible cases.

Is there a way to Bata test this on large setups? What
if you make the default Kconfig(urable) so DISTROs can
compile with a new default and have a large scale testing
like in a rawhide version.

Thanks
Boaz
