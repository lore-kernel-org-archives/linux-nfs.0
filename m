Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:35181 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab0JMN4i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 09:56:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by filter.openoffice.nl (Postfix) with ESMTP id 98E81243FF9
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 15:56:37 +0200 (CEST)
Received: from filter.openoffice.nl ([127.0.0.1])
	by localhost (post-it.openoffice.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ULDR4VqVINrr for <linux-nfs@vger.kernel.org>;
	Wed, 13 Oct 2010 15:56:32 +0200 (CEST)
Received: from blub.net (095-097-076-243.static.chello.nl [95.97.76.243])
	by filter.openoffice.nl (Postfix) with ESMTP id 35FD92439F2
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 15:56:32 +0200 (CEST)
Received: from stout.kantoor.openoffice.nl (stout.kantoor.openoffice.nl [192.168.112.50])
	by blub.net (Postfix) with ESMTP id 0C5D0300052
	for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 15:56:32 +0200 (CEST)
Message-ID: <4CB5BA8F.2090608@blub.net>
Date: Wed, 13 Oct 2010 15:56:31 +0200
From: Valentijn Sessink <valentyn@blub.net>
To: linux-nfs@vger.kernel.org
Subject: Re: ipv6 + krb5, server status?
References: <4CB59086.9080108@blub.net>	<20101013125656.GA5197@merit.edu> <20101013095216.5b9b31a7@corrin.poochiereds.net>
In-Reply-To: <20101013095216.5b9b31a7@corrin.poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff Layton schreef:
> As of nfs-utils-1.2.3, IPv6 server-side support should be
> "complete" (modulo bugs, of course).

Which is "correct" (I copied the quotation marks, because I tested very
inextensively). What I'm wondering about is the combination with
Kerberos. I'm currently setting up a better testing environment.

V.

