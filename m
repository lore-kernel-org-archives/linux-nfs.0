Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:37771 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbeFDV1H (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 17:27:07 -0400
Date: Mon, 4 Jun 2018 14:27:04 -0700
From: Tejun Heo <tj@kernel.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: "linux-security-module@vger.kernel.org"
        <linux-security-module@vger.kernel.org>, chandan.vn@samsung.com,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        CPGS <cpgs@samsung.com>,
        Sireesha Talluri <sireesha.t@samsung.com>,
        Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] Smack: Fix memory leak in smack_inode_getsecctx
Message-ID: <20180604212704.GC1351649@devbig577.frc2.facebook.com>
References: <1527758911-18610-1-git-send-email-chandan.vn@samsung.com>
 <20180531153943.GR1351649@devbig577.frc2.facebook.com>
 <4f00f9ae-3302-83b9-c083-d21ade380eb2@schaufler-ca.com>
 <20180531161107.GV1351649@devbig577.frc2.facebook.com>
 <20180601085609epcms5p5fefac0156a4816e9e48751211ab595ee@epcms5p5>
 <CGME20180531092848epcas1p24b638ccd6da00f1e039bdb64de7e1a5b@epcms5p7>
 <20180601162913epcms5p7737f5b4376d8865af1eae119aa866550@epcms5p7>
 <5b0b157a-0e8c-d8f5-901e-836d545a8e4c@schaufler-ca.com>
 <fa278910-5c99-11dc-c9cb-b88a97592e53@schaufler-ca.com>
 <b6cc4bd5-8d79-bbc2-373f-ea0bf0806884@schaufler-ca.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <b6cc4bd5-8d79-bbc2-373f-ea0bf0806884@schaufler-ca.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 04, 2018 at 02:01:34PM -0700, Casey Schaufler wrote:
> On 6/1/2018 10:45 AM, Casey Schaufler wrote:
> > Fix memory leak in smack_inode_getsecctx
> >
> > The implementation of smack_inode_getsecctx() made
> > incorrect assumptions about how Smack presents a security
> > context. Smack does not need to allocate memory to support
> > security contexts, so "releasing" a Smack context is a no-op.
> > The code made an unnecessary copy and returned that as a
> > context, which was never freed. The revised implementation
> > returns the context correctly.
> >
> > Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
> 
> Tejun, does this pass your tests?

Oh, I'm not the one who reported.  Chandan?

-- 
tejun
