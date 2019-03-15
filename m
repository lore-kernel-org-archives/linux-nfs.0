Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39C0BC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 12A532063F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727250AbfCOTwe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 15:52:34 -0400
Received: from mx1.redhat.com ([209.132.183.28]:35082 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727272AbfCOTwd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Mar 2019 15:52:33 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 993387C0BB;
        Fri, 15 Mar 2019 19:52:33 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-19.rdu2.redhat.com [10.10.122.19])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 7BE745DD93;
        Fri, 15 Mar 2019 19:52:33 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 1A27920C35; Fri, 15 Mar 2019 15:52:33 -0400 (EDT)
Date:   Fri, 15 Mar 2019 15:52:33 -0400
From:   Scott Mayhew <smayhew@redhat.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [pynfs PATCH 1/4] nfs4.1: add some reboot tests
Message-ID: <20190315195233.GY4975@coeurl.usersys.redhat.com>
References: <20190314211210.7454-1-smayhew@redhat.com>
 <20190314211210.7454-2-smayhew@redhat.com>
 <20190315194344.GA13567@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315194344.GA13567@fieldses.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 15 Mar 2019 19:52:33 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 15 Mar 2019, J. Bruce Fields wrote:

> On Thu, Mar 14, 2019 at 05:12:07PM -0400, Scott Mayhew wrote:
> > +def doTestRebootWithNClients(t, env, n=10):
> > +    boot_time = int(time.time())
> > +    lease_time = 90
> 
> Looks like these two variables aren't used till they're set again a
> little further down, so I'll delete these two lines.

The intention there was to have some default values for the exception
handler if the test were to barf right away for some reason.
> 
> --b.
> 
> > +    states = []
> > +    block = env.c1.new_client_session("%s_block" % env.testname(t))
> > +    for i in range(n):
> > +        name = "%s_client_%i" % (env.testname(t), i)
> > +        owner = "owner_%s" % name
> > +        c = env.c1.new_client(name)
> > +        sess = c.create_session()
> > +        reclaim_complete(sess)
> > +        fh, stateid = create_confirm(sess, owner)
> > +        states.append(State(name, owner, c, sess, fh))
> > +    lease_time = _getleasetime(sess)
> > +    boot_time = _waitForReboot(env)
