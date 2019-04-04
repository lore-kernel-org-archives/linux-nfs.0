Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8064C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 01:06:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ACA682082E
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 01:06:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726167AbfDDBF7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Apr 2019 21:05:59 -0400
Received: from fieldses.org ([173.255.197.46]:58540 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726099AbfDDBF7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Apr 2019 21:05:59 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 691071C1E; Wed,  3 Apr 2019 21:05:59 -0400 (EDT)
Date:   Wed, 3 Apr 2019 21:05:59 -0400
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: directory delegations
Message-ID: <20190404010559.GA17840@fieldses.org>
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
 <20190402161116.GA2828@fieldses.org>
 <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
 <20190402194148.GA5269@fieldses.org>
 <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
 <20190403002822.GA7667@fieldses.org>
 <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
 <20190403020750.GA8272@fieldses.org>
 <c538dd35-fd1f-bab6-1cd3-6c9639462eab@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c538dd35-fd1f-bab6-1cd3-6c9639462eab@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Apr 03, 2019 at 12:56:24PM -0400, Bradley C. Kuszmaul wrote:
> This proposal does look like it would be helpful.   How does this
> kind of proposal play out in terms of actually seeing the light of
> day in deployed systems?

We need some people to commit to implementing it.

We have 2-3 testing events a year, so ideally we'd agree to show up with
implementations at one of those to test and hash out any issues.

We revise the draft based on any experience or feedback we get.  If
nothing else, it looks like it needs some updates for v4.2.

The on-the-wire protocol change seems small, and my feeling is that if
there's running code then documenting the protocol and getting it
through the IETF process shouldn't be a big deal.

--b.

> On 4/2/19 10:07 PM, bfields@fieldses.org wrote:
> >On Wed, Apr 03, 2019 at 02:02:54AM +0000, Trond Myklebust wrote:
> >>The create itself needs to be sync, but the attribute delegations mean
> >>that the client, not the server, is authoritative for the timestamps.
> >>So the client now owns the atime and mtime, and just sets them as part
> >>of the (asynchronous) delegreturn some time after you are done writing.
> >>
> >>Were you perhaps thinking about this earlier proposal?
> >>https://urldefense.proofpoint.com/v2/url?u=https-3A__tools.ietf.org_html_draft-2Dmyklebust-2Dnfsv4-2Dunstable-2Dfile-2Dcreation-2D01&d=DwIBAg&c=RoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=YIKOmJLMLfe5wQR3VJI7jGjCnepZlMwumApzvaKItrY&m=qlAJ6dZPGjbcTzNIpkTyk-RTii6lWw1CLIjF6jp3P2Y&s=aTTFNJlRH-dXrQmE4cSYEUd8Kv3ij5cqTJtvgIixMa8&e=
> >That's it, thanks!
> >
> >Bradley is concerned about performance of something like untar on a
> >backend filesystem with particularly high-latency metadata operations,
> >so something like your unstable file createion proposal (or actual write
> >delegations) seems like it should help.
> >
> >--b.
