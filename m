Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090AbaHMN71 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2014 09:59:27 -0400
Message-ID: <53EB6F3C.2040200@RedHat.com>
Date: Wed, 13 Aug 2014 09:59:24 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Henrique Martins <linux@martins.cc>, linux-nfs@vger.kernel.org
Subject: Re: nfs-utils.spec patch
References: <bug-1115179-43722@bugzilla.redhat.com> <bug-1115179-43722-GPTO0t3XWU@bugzilla.redhat.com> <25446.1407076487@monster.martins.cc>
In-Reply-To: <25446.1407076487@monster.martins.cc>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/03/2014 10:34 AM, Henrique Martins wrote:
> 
> The spec file for nfs-utils-1.3.0-2.1.fc20 (nfs-utils.spec)
> has a bunch of bad date entries in %changelog which cause
> warnings when running rpmbuild.
> 
> Patch attached, by changing the weekday to match the day
> number.

Thanks for doing this!!! I definitely appreciated it!! 

I just did the commit on all three branches (f20,f21,master)
but I didn't rebuild anything... If you need something 
rebuilt, just let me know... 

thanks again! 

steved.
