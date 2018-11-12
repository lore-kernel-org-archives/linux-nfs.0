Return-Path: <SRS0=lcGf=NX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54581C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 23:01:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F3349223DD
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 23:01:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3349223DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726180AbeKMI5G (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 13 Nov 2018 03:57:06 -0500
Received: from fieldses.org ([173.255.197.46]:45648 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726014AbeKMI5G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Nov 2018 03:57:06 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id DA14D1E3D; Mon, 12 Nov 2018 18:01:49 -0500 (EST)
Date:   Mon, 12 Nov 2018 18:01:49 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "schumakeranna@gmail.com" <schumakeranna@gmail.com>,
        "chucklever@gmail.com" <chucklever@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NULL dereference in rpcauth_lookup_credcache
Message-ID: <20181112230149.GF16755@fieldses.org>
References: <20181108214452.GH6090@fieldses.org>
 <04114B00-B5A8-4F8A-B052-A266AED7725D@gmail.com>
 <20181110214939.GA16755@fieldses.org>
 <c986450a2d19fa796078ed51b9d0fb8a79eda696.camel@hammerspace.com>
 <20181112182454.GE16755@fieldses.org>
 <2e62a77385b4e5d91e2ca9128313cf817c46a1ae.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2e62a77385b4e5d91e2ca9128313cf817c46a1ae.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 12, 2018 at 09:17:16PM +0000, Trond Myklebust wrote:
> On Mon, 2018-11-12 at 13:24 -0500, bfields@fieldses.org wrote:
> > On Mon, Nov 12, 2018 at 05:59:33PM +0000, Trond Myklebust wrote:
> > > On Sat, 2018-11-10 at 16:49 -0500, Bruce Fields wrote:
> > > > Looks like it's the fault of
> > > > 
> > > > 07d02a67b7faae "SUNRPC: Simplify lookup code"
> > > 
> > > I'm having trouble reproducing this bug. I've tried both cthon and
> > > xfstests in a loop, so far without success (both NFSv3 and v4.1,
> > > but
> > > only sec=sys). Is there anything else you're doing that I might
> > > try?
> > > 
> > > e.g. Are you running multiple workloads in parallel? Different
> > > users?..
> > 
> > Nothing that interesting.  Currently it's connectathon over v4, v3,
> > v4/krb5, v3/krb5, v4/krb5i, v4/krb5p, v4.1, v4.1/krb5, but just
> > serially
> > one after the other.  Then some pynfs tests (which bypass the
> > client),
> > then xfstests over v4.2/sys.  And also a few one-off locking tests of
> > my
> > own that probably aren't a factor here.
> > 
> > (Hah, I just realized I was mounting with vers=4 and assuming that
> > meant
> > 4.0, but actually it's changed over time depending on the defaults,
> > so
> > currently those "v4" runs are actually all 4.2.  Gah.)
> 
> Are you perhaps both using RPCSEC_GSS w/ integrity checking for your
> EXCHANGE_ID authentication? The client will attempt to use that by
> default if rpc.gssd is running.

Yes, in addition to the krb5i mount I'd expect the sys/krb5/krb5p mounts
are using krb5i for EXCHANGE_ID.

> I ask because I think the issue might be with RPCSEC_GSS, specifically
> with the RPCSEC_GSS context destroy code, hence the 2 patches that I
> just sent out.

Looks like my tests pass after applying those two patches.

--b.
