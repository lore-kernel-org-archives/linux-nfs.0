Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66E80C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 20:53:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1C6DB20824
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 20:53:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C6DB20824
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726050AbeJ3Fnu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 30 Oct 2018 01:43:50 -0400
Received: from mx1.redhat.com ([209.132.183.28]:43830 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726016AbeJ3Fnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Oct 2018 01:43:49 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1E04E8CDC;
        Mon, 29 Oct 2018 20:53:28 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-122-128.rdu2.redhat.com [10.10.122.128])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D31245D75C;
        Mon, 29 Oct 2018 20:53:27 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id BD67F18016C; Mon, 29 Oct 2018 16:53:26 -0400 (EDT)
Date:   Mon, 29 Oct 2018 16:53:26 -0400
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 00/13] server-side support for "inter" SSC copy
Message-ID: <20181029205326.GA19671@parsley.fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181025160739.GC5539@fieldses.org>
 <CAN-5tyF14PZztzVyYXXxZMSUEg6DiQpb0cnfUxXZk-qE2ChrpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyF14PZztzVyYXXxZMSUEg6DiQpb0cnfUxXZk-qE2ChrpA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 29 Oct 2018 20:53:28 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 29, 2018 at 01:54:37PM -0400, Olga Kornievskaia wrote:
> On Thu, Oct 25, 2018 at 12:08 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Oct 19, 2018 at 11:28:52AM -0400, Olga Kornievskaia wrote:
> > > This patch series adds support for NFSv4.2 copy offload feature
> > > allowing copy between two different NFS servers.
> >
> > Apologies, it may take me another week or so to get to this....
> >
> > This is the part that sounds trickiest!:
> 
> I'll look for your comments next week. Please note that client side
> patches that NFSD depends on have changed (due to the client side
> review) so to run/compile the code, please grab all of the latest
> client-side patches that I posted.

OK, thanks.

> I'm assuming that async patches are going into 4.20, correct?

Yes.

--b.
