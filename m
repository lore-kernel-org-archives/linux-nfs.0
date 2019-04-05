Return-Path: <SRS0=4THU=SH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1342C282CE
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 20:43:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A947E206BA
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 20:43:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726409AbfDEUnf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 Apr 2019 16:43:35 -0400
Received: from fieldses.org ([173.255.197.46]:60828 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726204AbfDEUnf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 Apr 2019 16:43:35 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id E03FA1D39; Fri,  5 Apr 2019 16:43:34 -0400 (EDT)
Date:   Fri, 5 Apr 2019 16:43:34 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v3 0/5] un-deprecate nfsdcld
Message-ID: <20190405204334.GD8397@fieldses.org>
References: <20190326220630.2911-1-smayhew@redhat.com>
 <20190328211726.GA31938@fieldses.org>
 <20190329121609.GA3659@coeurl.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329121609.GA3659@coeurl.usersys.redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Mar 29, 2019 at 08:16:09AM -0400, Scott Mayhew wrote:
> On Thu, 28 Mar 2019, J. Bruce Fields wrote:
> > Thanks!  It looks good to me on a first skim, but I probably won't get a
> > proper look at it till next week.
> > 
> > You say "RFC"--are there still known issue that you're working on?
> 
> No, I just added RFC because of the new stuff I added for handling the
> legacy records.  Plus I wasn't sure if you would have a problem with the
> server not lifting the grace period early if there were legacy records.
> I could do it if I moved some code out of nfs4recover.c but I chose not
> to since it should really be a one-time thing and the original legacy
> tracking didn't lift the grace period early anyway.

Yeah, I don't think that case is worth spending time optimizing.

The kernel patches look OK to me.  I'm inclined to target them for the
next merge window (5.2).  If Jeff has the time to take a look, it'd also
be good to know if he has any more concerns.

--b.
