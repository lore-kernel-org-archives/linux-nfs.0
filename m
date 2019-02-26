Return-Path: <SRS0=yawm=RB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDD69C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 19:46:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 95CB221850
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 19:46:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727998AbfBZTqG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Feb 2019 14:46:06 -0500
Received: from fieldses.org ([173.255.197.46]:59344 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727196AbfBZTqG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Feb 2019 14:46:06 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 38BA31C98; Tue, 26 Feb 2019 14:46:06 -0500 (EST)
Date:   Tue, 26 Feb 2019 14:46:06 -0500
To:     David Noveck <davenoveck@gmail.com>
Cc:     "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        linux-nfs-owner <linux-nfs-owner@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>, NFSv4 <nfsv4@ietf.org>,
        Ganesha-devel <devel@lists.nfs-ganesha.org>
Subject: Re: [nfsv4] file size and getattr
Message-ID: <20190226194606.GA12035@fieldses.org>
References: <155049372736.14318.3390584694682770373.idtracker@ietfa.amsl.com>
 <CADaq8je2Ap4oAZAPOguaWctUs8dQ=Q9g=TO39EOiJW5EJSFTGg@mail.gmail.com>
 <OFE5A6CD32.4DC48078-ON882583A9.007FB4BC-882583A9.0080ACAC@notes.na.collabserv.com>
 <CADaq8jfT=nxmVPz4mDRFAaOx36uxWqKbxitqS-YH3GCOs4CsrQ@mail.gmail.com>
 <741516773.7109032.1551084577150.JavaMail.zimbra@desy.de>
 <CADaq8jdp7qVOE9aKui-tgrk00hVmNVXP=yjQ_G-RtGm+G4VrYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADaq8jdp7qVOE9aKui-tgrk00hVmNVXP=yjQ_G-RtGm+G4VrYw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 25, 2019 at 10:50:21AM -0500, David Noveck wrote:
> For example, if you (or another client) read data written unstably,
> and there was been no restart you will see bytes past the eof as known
> by the metadata server.

Possibly worth noting that if there *is* a restart, all bets are off.

And how do you know there hasn't been a restart?  Or if you can figure
that out (e.g. if you're using sessions), how do you know when clients
have finished retransmitting unstable write data?

I'd be curious what prompted the original question.

--b.
