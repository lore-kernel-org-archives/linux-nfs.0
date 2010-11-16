Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:57286 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755024Ab0KPTox (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 14:44:53 -0500
Message-ID: <4CE2DF2D.9070603@blub.net>
Date: Tue, 16 Nov 2010 20:44:45 +0100
From: Valentijn Sessink <valentyn@blub.net>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Strange rpc.svcgssd behavior
References: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com> <4CE2AA3B.6070302@openoffice.nl>
In-Reply-To: <4CE2AA3B.6070302@openoffice.nl>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Quoting myself: ...
Op 16-11-10 16:58, Valentijn Sessink schreef:
> We have been disabling NM for years now because of this.
>> Now I reboot, and NetworkManager happily adds "your.host	your" back to the "::1" entry, and rpc.svcgssd fails again.

... here's the long standing bug report for Ubuntu:
https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/8980

(Been there since 2004). Nobody uses hostnames anymore, I guess ;)

V.
