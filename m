Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 564F6C5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 17:47:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2A42A2082F
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 17:47:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A42A2082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729064AbeLJRrW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 12:47:22 -0500
Received: from fieldses.org ([173.255.197.46]:59404 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727324AbeLJRrV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Dec 2018 12:47:21 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id A7B081C56; Mon, 10 Dec 2018 12:47:20 -0500 (EST)
Date:   Mon, 10 Dec 2018 12:47:20 -0500
To:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Subject: listing knfsd-held locks and opens
Message-ID: <20181210174720.GA2925@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We've got a long-standing complaint that tools like lsof, when run on an
NFS server, overlook opens and locks held by NFS clients.

The information's all there, it's just a question of how to expose it.

Easiest might be a single flat file like /proc/locks, but I've always
hoped we could do something slightly more structured, using a
subdirectory per NFS client.

Jeff Layton looked into this several years ago.  I don't remember if
there was some particular issue or if he just got bogged down in VFS
details.

My concerns are that:

	- I'd like the format to be easily expandable.  The option to
	  create new files seems like it would help.
	- some of the data we'd like to expose may be kind of cumbersome
	  include as a column in a text file.  (I'm thinking of the
	  NFSv4 client identifier, which the protocol allows to be up to
	  1K of binary data, even if most (all?) clients use shorter
	  ascii identifiers.)

I'm not sure I'd want to go as far as a sysfs-like one-value-per-file
rule, which seems like overkill?

In a little more detail, as starting point, I was considering naming
each client directory with a small integer, and including files like:

	info: a text file with
		NFS protocol version
		ascii representation of client address
		krb5 principal if available

	clientid: NFSv4 client ID; file absent for NFSv2/3 clients.

	locks: list of locks, following something like the /proc/locks
		format.

	opens: list of file opens, with access bits, inode numbers,
		device number.

Does that sound reasonable?  Any other ideas?

--b.
