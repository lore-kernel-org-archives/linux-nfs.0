Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12217 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735AbaIWPbc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 11:31:32 -0400
Message-ID: <5421924F.3010406@RedHat.com>
Date: Tue, 23 Sep 2014 11:31:27 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-server: Replace rpc.svcgssd with gssproxy in
 systemd script
References: <1411146621-18797-1-git-send-email-steved@redhat.com>	<1411146621-18797-2-git-send-email-steved@redhat.com>	<541C892D.7020401@RedHat.com> <20140923112352.28917775@notabene.brown> <542189F6.1050406@RedHat.com>
In-Reply-To: <542189F6.1050406@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/23/2014 10:55 AM, Steve Dickson wrote:
> So I guess at the end of the day... I want to break the 'Unknown' Wants rule... ;-) 
> By adding a dependency to gssproxy and by having nfs-server 'want' the gssproxy
> service...  Its the cleanest way... IMHO... 

As Simo just pointed out...  nfs-utils does not need to require 
gssproxy to be installed... When its not installed, rpc.svcgssd 
will be started when it is, gssproxy will be started. 

steved.
