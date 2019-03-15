Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D8DAC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 20:50:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 22438218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 20:50:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726833AbfCOUuU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 16:50:20 -0400
Received: from fieldses.org ([173.255.197.46]:33892 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725990AbfCOUuU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Mar 2019 16:50:20 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id EBB2C1C83; Fri, 15 Mar 2019 16:50:19 -0400 (EDT)
Date:   Fri, 15 Mar 2019 16:50:19 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [pynfs PATCH 1/4] nfs4.1: add some reboot tests
Message-ID: <20190315205019.GC13567@fieldses.org>
References: <20190314211210.7454-1-smayhew@redhat.com>
 <20190314211210.7454-2-smayhew@redhat.com>
 <20190315194344.GA13567@fieldses.org>
 <20190315195233.GY4975@coeurl.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315195233.GY4975@coeurl.usersys.redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Mar 15, 2019 at 03:52:33PM -0400, Scott Mayhew wrote:
> On Fri, 15 Mar 2019, J. Bruce Fields wrote:
> 
> > On Thu, Mar 14, 2019 at 05:12:07PM -0400, Scott Mayhew wrote:
> > > +def doTestRebootWithNClients(t, env, n=10):
> > > +    boot_time = int(time.time())
> > > +    lease_time = 90
> > 
> > Looks like these two variables aren't used till they're set again a
> > little further down, so I'll delete these two lines.
> 
> The intention there was to have some default values for the exception
> handler if the test were to barf right away for some reason.

Oh, I see, OK.

--b.

> > 
> > --b.
> > 
> > > +    states = []
> > > +    block = env.c1.new_client_session("%s_block" % env.testname(t))
> > > +    for i in range(n):
> > > +        name = "%s_client_%i" % (env.testname(t), i)
> > > +        owner = "owner_%s" % name
> > > +        c = env.c1.new_client(name)
> > > +        sess = c.create_session()
> > > +        reclaim_complete(sess)
> > > +        fh, stateid = create_confirm(sess, owner)
> > > +        states.append(State(name, owner, c, sess, fh))
> > > +    lease_time = _getleasetime(sess)
> > > +    boot_time = _waitForReboot(env)
