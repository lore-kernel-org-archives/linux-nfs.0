Return-Path: <SRS0=sR+C=NW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E60AC43441
	for <linux-nfs@archiver.kernel.org>; Sun, 11 Nov 2018 10:08:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C65F820854
	for <linux-nfs@archiver.kernel.org>; Sun, 11 Nov 2018 10:08:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C65F820854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727462AbeKKT4c (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 11 Nov 2018 14:56:32 -0500
Received: from mx1.redhat.com ([209.132.183.28]:42130 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727448AbeKKT4c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 11 Nov 2018 14:56:32 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D114C308A96E;
        Sun, 11 Nov 2018 10:08:24 +0000 (UTC)
Received: from localhost (ovpn-117-40.ams2.redhat.com [10.36.117.40])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 606A85D717;
        Sun, 11 Nov 2018 10:08:24 +0000 (UTC)
Date:   Sun, 11 Nov 2018 11:08:22 +0100
From:   Niels de Vos <ndevos@redhat.com>
To:     Naruto Nguyen <narutonguyen2018@gmail.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount client port allocated in privilege port range
Message-ID: <20181111100822.GB4421@ndevos-x270>
References: <CANpxKHEmtZkfcFVhxyrF0PZ2TwTNHCGgYN4qNZu2dn=GasbOVg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANpxKHEmtZkfcFVhxyrF0PZ2TwTNHCGgYN4qNZu2dn=GasbOVg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Sun, 11 Nov 2018 10:08:24 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Nov 10, 2018 at 10:48:41AM +0700, Naruto Nguyen wrote:
> Hi everyone,
> 
> When running mount command with tcp under root account, I see that the
> tcp client port is allocated in privilege range like 830... I do not
> think it's a good behavior as port in privilege range is limited and a
> lot of well known service is using it. Could you please let me know
> any reason for that? It's better for mount nfs client port to be
> allocated in dynamic port range instead even the system is running
> under root permission? and any other way to make it happens besides
> running under a normal user?

Have a look at 'man 5 nfs' and search for the "noresvport" option. You
will also want to read the "Using non-privileged source ports"
paragraph.

HTH,
Niels
