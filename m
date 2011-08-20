Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36646 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753621Ab1HTQ7T convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Aug 2011 12:59:19 -0400
Subject: Re: Odd locking behavior
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Kelsey Cummings <kgc@corp.sonic.net>
Cc: linux-nfs@vger.kernel.org
Date: Sat, 20 Aug 2011 12:59:02 -0400
In-Reply-To: <20110819230151.GD44681@corp.sonic.net>
References: <20110819230151.GD44681@corp.sonic.net>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1313859542.7693.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-08-19 at 16:01 -0700, Kelsey Cummings wrote: 
> I'm looking for some suggestions as to where to look next with an odd
> nfs file locking problem with linux clients (RHEL6) and a netapp server.
> FSC is enabled on these.
> 
> The rather simple example code and output says it all.  It works as
> expected when a single process is run, when a second proccess is started
> it works for a while and then something breaks and we start seeing it
> take multiples of 30 seconds for the lock request to succeed.  The more
> proccess that are run, the more likely it is to occur as well as if a
> proccess is started on a second client.
> 
> When the issue is exhibiting itself, the netaps' lock status display the
> granted and waiting locks as expected(?).

Does the netapp filer have multiple NICs? There is a known bug with that
in which the filer sends GRANTED calls from the wrong IP address: see
the description at
http://now.netapp.com/NOW/cgi-bin/bol?Type=Detail&Display=237430

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

