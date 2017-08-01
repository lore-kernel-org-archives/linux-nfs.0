Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:58106 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbdHAPvg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 11:51:36 -0400
Date: Tue, 1 Aug 2017 11:51:31 -0400
From: "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
Message-ID: <20170801155131.xy7nbw5ih7ml5fmf@codemonkey.org.uk>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
 <20170716211530.sx7mn35f2mhmykug@codemonkey.org.uk>
 <1500245845.13893.3.camel@primarydata.com>
 <20170717030504.qca74wsswct26ytn@codemonkey.org.uk>
 <CA+55aFy6kUwPTbzKebO4=BovEc_Nq3XCoYMeofgCM3ypxrkvJg@mail.gmail.com>
 <20170731154322.tfzkukscda4fe7wm@codemonkey.org.uk>
 <CA+55aFwwkc-YJ8WQzE6Ax3BAJ3XXR8fhN+0AEH_U8TtcQn7opg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFwwkc-YJ8WQzE6Ax3BAJ3XXR8fhN+0AEH_U8TtcQn7opg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 31, 2017 at 10:35:45PM -0700, Linus Torvalds wrote:
 > On Mon, Jul 31, 2017 at 8:43 AM, davej@codemonkey.org.uk
 > <davej@codemonkey.org.uk> wrote:
 > > Another NFSv4 KASAN splat, this time from rc3.
 > >
 > > BUG: KASAN: use-after-free in nfs4_exchange_id_done+0x3d7/0x8e0 [nfsv4]
 > 
 > Ugh. It's really hard to tell what access that it - KASAN doesn't
 > actually give enough information. There's lots of 8-byte accesses
 > there in that function.
 > 
 > Any chance of getting the output from
 > 
 >    ./scripts/faddr2line vmlinux nfs4_exchange_id_done+0x3d7/0x8e0
 

Hm, that points to this..

7463                 /* Save the EXCHANGE_ID verifier session trunk tests */
7464                 memcpy(clp->cl_confirm.data, cdata->args.verifier->data,
7465                        sizeof(clp->cl_confirm.data));

	Dave

