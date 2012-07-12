Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932528Ab2GLO6i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jul 2012 10:58:38 -0400
Message-ID: <4FFEE612.8060406@RedHat.com>
Date: Thu, 12 Jul 2012 10:58:26 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jiri Horky <jiri.horky@cesnet.cz>
CC: linux-nfs@vger.kernel.org
Subject: Re: idmapd client-side static mapping
References: <4FFED6FA.4070407@cesnet.cz>
In-Reply-To: <4FFED6FA.4070407@cesnet.cz>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/12/2012 09:54 AM, Jiri Horky wrote:
> Hi,
> 
> man pages for idmapd.conf states possibility to use Static mapping. Looking at the source code of libnfsidmap v0.24, it is clear that static mappings are only valid for server side (svcgssd) which the man page forgets to mention. Is there any specific reason why not to implement the static resolution functions on the client side as well?
That is a good question... I always wonders this myself....

> 
> I would send a patch if there is a change it will be accepted.
There is only one way to find out! ;-)

steved.
