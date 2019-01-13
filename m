Return-Path: <SRS0=5R5j=PV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AB0FC43387
	for <linux-nfs@archiver.kernel.org>; Sun, 13 Jan 2019 03:04:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B805C2086C
	for <linux-nfs@archiver.kernel.org>; Sun, 13 Jan 2019 03:04:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=fordham-edu.20150623.gappssmtp.com header.i=@fordham-edu.20150623.gappssmtp.com header.b="AosNOz41"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726537AbfAMDEk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 12 Jan 2019 22:04:40 -0500
Received: from mail-ot1-f53.google.com ([209.85.210.53]:44423 "EHLO
        mail-ot1-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726480AbfAMDEj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Jan 2019 22:04:39 -0500
Received: by mail-ot1-f53.google.com with SMTP id f18so16511451otl.11
        for <linux-nfs@vger.kernel.org>; Sat, 12 Jan 2019 19:04:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=fordham-edu.20150623.gappssmtp.com; s=20150623;
        h=mime-version:from:date:message-id:subject:to;
        bh=y6eatHqoUr8+b7QOgKEoeg+nllsGb7zNsi0AStDvUEU=;
        b=AosNOz41JUXOdpj5ETOaTW7FaC4QjF8BE3U1Y4tcKD1oeHQr3YKvALFy8IVLQVnxJP
         WbhWTz60KXmacK8bK2UmwkoHB5jMD2wcBKrl4cn0DTA3KBOLmFyA+teJZ8idrFLSZ24V
         nD8ZPQ+4w9eD7rzexdP0h53Z9XsVuILQb9UpjxsNLJKNjxsuGiB8xEq9vBu4gZBaV4Jf
         Lmy9niH8ZvC6h6AecoAqM8EHY2c+8sNcFhGm24K/lffNoyeLfcRhEmgXIgR5LvHgYOsN
         WlHjM6rtnrrIBHonxKDyMdFcMQTTwEdNVTOVzzfyXOcDnAdjlCRgn6DIxx2Bh5HrbDA/
         JDrw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=y6eatHqoUr8+b7QOgKEoeg+nllsGb7zNsi0AStDvUEU=;
        b=CeHuR0vqGKh+sjEJefJQqCXwPd7c41AWM1JOAGFcmPGm9yvsm82oEhtNv/hz6wq4OF
         ptb8OsEXF6hGdz5Pmf+RHn9rQc2ya77EQoG3/RuVabFF3QqkI4/HOY7JPbytHdFYIAXW
         flgimELAWSQzLRljcDvfRlDxFlhxYqw5Y0cGYObpcUB74c6hD1rKU3+M7bRURevqhTfd
         R3gCkF/9Eryt2/GzwfzOhcvWuE2QyL8c1hXqrgQ7H+gO9lwas6BwgxfV4VxiL6gBDkG7
         qfmE1yALFg4Lv8OWcf8OvIRTR+1CuLp4sBdrYNgkhQnhXcpXHSUjxEpF1aJTTfxE3dcN
         GaDg==
X-Gm-Message-State: AJcUukdIDUQvLvokPbjuPhaA7g3RQ0R6LQ+1ywi1a2GGfBoQO7YcZK76
        0tULfb1Q76DpUpq9yEMeqsJEcudxrtP1oteuPABmG0pRTQI=
X-Google-Smtp-Source: ALg8bN5kSRLQdztX4I4Bq5qNYlfIYllPoCLB20xHZ+YolDCMRKuIXHj6a2Rgu5Ag7a4JHUM7DYF0U2iygo60GIugzk8=
X-Received: by 2002:a9d:5183:: with SMTP id y3mr12490329otg.5.1547348678526;
 Sat, 12 Jan 2019 19:04:38 -0800 (PST)
MIME-Version: 1.0
From:   Robert Kudyba <rkudyba@fordham.edu>
Date:   Sat, 12 Jan 2019 22:04:28 -0500
Message-ID: <CAFHi+KRT3Bjub6OeBH_yejOMKy9CUp4Y+XjVK9aT=TKeBZ=_yg@mail.gmail.com>
Subject: nfs-utils-2.3.3 RPC: Program not registered rpcb_getaddr (domain.com) failed
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

 posted this on the Fedora/RedHat Bugzilla at id 1665536

firewalld is off but just today NIS logins stopped working. yppasswd
is erroring out with:
ourdomain: RPC: Program not registered
yppasswd: rpcb_getaddr (ourdomain) failed!

4.19.13-300.fc29.x86_64
nfs-utils-2.3.3-0.fc29.x86_64
ypserv-4.0-12.20170331git5bfba76.fc29.x86_64

ypserv debug has:
Jan 11 11:43:05 ourdomain ypserv[21961]: #011ypdb_open("ourdomain",
"hosts.byname")
Jan 11 11:43:05 ourdomain ypserv[21961]: Found: ourdomain/hosts.byname (8)
Jan 11 11:43:05 ourdomain ypserv[21961]: ypdb_close() called
Jan 11 11:43:05 ourdomain ypserv[21961]: #011-> Error #-3

I've reported this error in the past in BZ 1478129 and BZ 1488616.
Just in case it appears nfs-utils upgraded over night and I manually
downgrade but same errors:
2019-01-11T14:47:30Z DDEBUG Command: dnf install -y nfs-utils
2019-01-11T14:47:30Z DDEBUG Installroot: /
2019-01-11T14:47:30Z DDEBUG Releasever: 29
2019-01-11T14:47:30Z DEBUG cachedir: /var/cache/dnf
2019-01-11T14:47:30Z DDEBUG Base command: install
2019-01-11T14:47:30Z DDEBUG Extra commands: ['install', '-y', 'nfs-utils']

Some proof that this was the results of an update to NFS.

file /etc/systemd/system/nfs-*.service.requires/nfs*
/etc/systemd/system/nfs-blkmap.service.requires/nfs-convert.service:
broken symbolic link to /usr/lib/systemd/system/nfs-convert.service
/etc/systemd/system/nfs-idmapd.service.requires/nfs-convert.service:
broken symbolic link to /usr/lib/systemd/system/nfs-convert.service
/etc/systemd/system/nfs-mountd.service.requires/nfs-convert.service:
broken symbolic link to /usr/lib/systemd/system/nfs-convert.service
/etc/systemd/system/nfs-server.service.requires/nfs-convert.service:
broken symbolic link to /usr/lib/systemd/system/nfs-convert.service

file /etc/systemd/system/rpc-*.service.requires/nfs*
/etc/systemd/system/rpc-gssd.service.requires/nfs-convert.service:
    broken symbolic link to
/usr/lib/systemd/system/nfs-convert.service
/etc/systemd/system/rpc-statd-notify.service.requires/nfs-convert.service:
broken symbolic link to /usr/lib/systemd/system/nfs-convert.service
/etc/systemd/system/rpc-statd.service.requires/nfs-convert.service:
    broken symbolic link to
/usr/lib/systemd/system/nfs-convert.service

So the update that creates a new /etc/nfs.conf file appears to be
related. I enabled UDP and this happens:
systemctl restart nfs-server
Failed to restart nfs-server.service: Unit nfs-convert.service not found.
Now see the broken pipe:

dnf reinstall nfs*
Last metadata expiration check: 0:06:50 ago on Sat 12 Jan 2019 08:29:40 PM EST.
Dependencies resolved.
Package                                Arch
    Version                                            Repository
                      Size

Reinstalling:
 nfs-utils                              x86_64
     1:2.3.3-1.rc2.fc29                                 updates
                      357 k

Transaction Summary

Total download size: 357 k
Installed size: 1.3 M
Is this ok [y/N]: y
Downloading Packages:
nfs-utils-2.3.3-1.rc2.fc29.x86_64.rpm
                                                                   209
kB/s | 357 kB     00:01
Total
                                                                   112
kB/s | 357 kB     00:03
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :

                        1/1
  Running scriptlet: nfs-utils-1:2.3.3-1.rc2.fc29.x86_64

                        1/1
  Running scriptlet: nfs-utils-1:2.3.3-1.rc2.fc29.x86_64

                        1/2
cut: write error: Broken pipe
cut: write error: Broken pipe

rpm -q nfs-utils
nfs-utils-2.3.3-1.rc2.fc29.x86_64
 rpm -V nfs-utils
SM5....T.  c /etc/nfs.conf
S.5....T.  c /etc/sysconfig/nfs
S.5....T.  c /var/lib/nfs/etab
.....UG..  g /var/lib/nfs/statd/state

I upgraded nfs-utils to nfs-utils-2.3.3-3.rc2.fc30.x86_64 enabled
debug setting to "all" in /etc/nfs.conf seeing this:
rpc.nfsd: knfsd is currently down

And the nfs service has disappeared:
systemctl status nfs
Unit nfs.service could not be found.
