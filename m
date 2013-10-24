Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw02.dd24.net ([193.46.215.43]:48450 "EHLO
	mailgw02.dd24.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754202Ab3JXQBT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 12:01:19 -0400
Received: from localhost (amavis02.dd24.net [192.168.1.113])
	by mailgw02.dd24.net (Postfix) with ESMTP id 1B489356BFA
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 16:01:15 +0000 (GMT)
Received: from mailgw02.dd24.net ([192.168.1.197])
	by localhost (amavis02.dd24.net [192.168.1.106]) (amavisd-new, port 10197)
	with ESMTP id V6An6ffk5QH0 for <linux-nfs@vger.kernel.org>;
	Thu, 24 Oct 2013 16:01:09 +0000 (GMT)
Received: from [192.168.0.102] (ppp-88-217-86-191.dynamic.mnet-online.de [88.217.86.191])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mailgw02.dd24.net (Postfix) with ESMTPSA id 89328356BED
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 16:01:09 +0000 (GMT)
Message-ID: <1382630468.6907.58.camel@heisenberg.scientia.net>
Subject: Re: XATTRs in NFS?
From: Christoph Anton Mitterer <calestyo@scientia.net>
To: linux-nfs@vger.kernel.org
Date: Thu, 24 Oct 2013 18:01:08 +0200
In-Reply-To: <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
	 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
	 <1382624000.6907.8.camel@heisenberg.scientia.net>
	 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-24 at 14:32 +0000, Myklebust, Trond wrote:
> Linux xattrs are a rabid mess.
Well... might be from a technical POV, but for users they're quite
useful in some scenarios.


> The whole "system" namespace is something that cannot and should not ever be exposed on a network.
> The "trusted" and "user" namespaces just offer specialised storage. Why are they needed?
Well what I do is attaching integrity information to files.

You may say now that this is similar to what btrfs will provide
anyway... but the problem with that is, that checksums are always
updated when something in the system does valid changes to the file.

What I however want is that I really manually have to set this, so that
I notice "accidental" changes, e.g. by myself or by buggy software...


> If the data needs to follow the file, then store it in the file. Why do you need the filesystem to manage that for you?
... and since this applies to arbitrary files, from text-files over
pictures, videos to binaries,... it's neither possible to store this in
the file, nor can I really track this with an database,... since
literally any program that uses such files, from the picture editor to
the file-manager would need to use such DB.


Cheers,
Chris.

