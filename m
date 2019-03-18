Return-Path: <SRS0=1lUO=RV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E91EAC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Mar 2019 14:30:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B6CDA2085A
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Mar 2019 14:30:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=mindspring.com header.i=@mindspring.com header.b="JvOM2wGx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727642AbfCROaW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Mar 2019 10:30:22 -0400
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:37922 "EHLO
        elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727183AbfCROaW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Mar 2019 10:30:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mindspring.com;
        s=dk12062016; t=1552919422; bh=WxzfRtAjPAoN6TgQI57Rj9ipipxUmJEgePij
        fR2aww8=; h=Received:From:To:Cc:References:In-Reply-To:Subject:Date:
         Message-ID:MIME-Version:Content-Type:Content-Transfer-Encoding:
         X-Mailer:Content-Language:Thread-Index:X-ELNK-Trace:
         X-Originating-IP; b=JvOM2wGxUfk2X26pd54iArk16/jh8oC7B1OL2TcDasONDm
        568aX641xlhcGU3MczOACxr8u2FUSXrDYv6o5aIlWlhXABL0ThLQpnGymSTVwV6wYq1
        4WfQG3Y01PaJXwoaVy/Ag+sd7nZqI4WjNrYO/0sPJXLwV0Trz/GQHEMU5dtcjzWVxzO
        4Yz943sTpv6UH95jtI6c6rkFBgdIgf1XbQY1vD9FDiHLI2rbCs4HMzQON2mI5eA3I12
        ErxJkX2Z1kJBDisFWzU0OeiJLeKSSx74NAkraQTAixrS4KJwGXVsBXNbYelzJ+ZupTF
        Gg9UMxqnHfy2Sf46yX5c7qSoLFJg==
DomainKey-Signature: a=rsa-sha1; q=dns; c=nofws;
  s=dk12062016; d=mindspring.com;
  b=eoUWzwHZPJZVJwYh3HFwl7fMNNP6ifLmsjaLM8IhB3lAju1IRmxeHftwa9nO2RKNh41BoBqLOA+keXJ8YTDX1B1DNbHrSpCVOymEFaCq0YLkTzkMoDA4k194yBR4Cu5QJccrdFhUEvr1V5o+3GtJc+0W+KInzQnNHlgJbRqFR6Wq9jwZ0PDA5/hVe9lf6JrPBKElT2h98Dm+2HADkLorxWLCvO8Uy/Xqwl6y4sJnsYbZFdWOy1kUi6gQODD2w7WzjXiHoGmi82mhAF4y8S2E1KcmZKwsohZ25qMU2Sm5yRwbQMdlU9UoRe1Z9rBDa2u1amVZ12LWKB3deDpD9LdTPg==;
  h=Received:From:To:Cc:References:In-Reply-To:Subject:Date:Message-ID:MIME-Version:Content-Type:Content-Transfer-Encoding:X-Mailer:Content-Language:Thread-Index:X-ELNK-Trace:X-Originating-IP;
Received: from [76.105.143.216] (helo=FRANKSTHINKPAD)
        by elasmtp-dupuy.atl.sa.earthlink.net with esmtpa (Exim 4)
        (envelope-from <ffilzlnx@mindspring.com>)
        id 1h5tHQ-000Fwq-Fh; Mon, 18 Mar 2019 10:30:20 -0400
From:   "Frank Filz" <ffilzlnx@mindspring.com>
To:     "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Scott Mayhew'" <smayhew@redhat.com>
Cc:     <jlayton@kernel.org>, <linux-nfs@vger.kernel.org>
References: <20190314211210.7454-1-smayhew@redhat.com> <20190314211210.7454-2-smayhew@redhat.com> <20190315204859.GB13567@fieldses.org>
In-Reply-To: <20190315204859.GB13567@fieldses.org>
Subject: RE: [pynfs PATCH 1/4] nfs4.1: add some reboot tests
Date:   Mon, 18 Mar 2019 07:30:20 -0700
Message-ID: <03cc01d4dd97$1df47ff0$59dd7fd0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
X-Mailer: Microsoft Outlook 15.0
Content-Language: en-us
Thread-Index: AQLJRflU5gZZ7y6x2nK4BtBk/Gn9owK9wYOoAXwcFbSkBtKUcA==
X-ELNK-Trace: 136157f01908a8929c7f779228e2f6aeda0071232e20db4d05942e9d75f954a52d2644e622c22005350badd9bab72f9c350badd9bab72f9c350badd9bab72f9c
X-Originating-IP: 76.105.143.216
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

> On Thu, Mar 14, 2019 at 05:12:07PM -0400, Scott Mayhew wrote:
> > +def testRebootWithManyManyManyClients(t, env):
> > +    """Reboot with many many many clients
> > +
> > +    FLAGS: reboot
> > +    CODE: REBT2c
> > +    """
> > +    return doTestRebootWithNClients(t, env, 1000)
> 
> My test server uses a 15 second lease time, mainly just to speed up tests.
That's
> not enough for pynfs to send out reclaims for 1000 clients.
> 
> So I'm wondering whether that's a reasonable test or not.
> 
> On the one hand, we should be able to handle 1000 clients, and a 15 second
> lease is probably unrealistically short.  And maybe we could choose more
patient
> behavior for the server (currently it will wait at most 2 grace periods
while
> reclaims continue to arrive).
> 
> On the other hand, real clients will send their reclaims simultaneously
rather
> than one at a time.  And from a trace it looks like most of the time's
spent
> waiting for pynfs to send the next request rather than waiting for
replies.  So this
> is a bit unusual.
> 
> I'm inclined to drop the "many many many clients" tests.  It's easy enough
for
> someone doing reboot testing to patch the tests if they need to.
> 
> By the way, the longest round trip time I see is the RECLAIM_COMPLETE.
> I assume that's doing a commit to disk.  It looks like there's nothing on
the
> server to prevent processing RECLAIM_COMPLETEs in parallel so as long as
> that's true I suppose we're OK.

How about having the many many many clients tests under a different flag so
they are still available but easy to pick or not pick?

Considering that CID5 with the huge number of client-ids it creates but
doesn't clean up (so they all eventually expire) has caught bugs in Ganesha,
I like the idea of messy big tests being available for QE to run...

Frank

