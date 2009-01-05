Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37602 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753388AbZAEUNr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2009 15:13:47 -0500
Message-ID: <496268F9.8010607@RedHat.com>
Date: Mon, 05 Jan 2009 15:09:29 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: By default,	don't spam syslog when users' credentials
 expire
References: <20081217173927.3031.53736.stgit@jazz.citi.umich.edu>
In-Reply-To: <20081217173927.3031.53736.stgit@jazz.citi.umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Kevin Coffman wrote:
> Change the priority of "common" log messages so that syslog doesn't get
> slammed/spammed when users' credentials expire, or there is another common
> problem which would cause error messages for all context creation requests.
> 
> Note that this will now require that gssd or svcgssd option "-v" is used to
> debug these common cases.
> 
> Original patch from Andrew Pollock <apollock@google.com>.
> 
Committed... 

This took a little longer than expected do to a fairly
nasty bug in the Fedora 10 installation....

The installation process adds both the FQDN and the host name
(i.e. the non-FQDN) to the 127.0.0.1 line in /etc/hosts. This
causes gethostname() on the FQDN to return 127.0.0.1 instead of 
DNS IP address... This caused svcgssd to always fail due to 
the host name not being found in the key tab. 

Unfortunately it took quite a bit to figure out what host name the
kerberos libs were looking since the host name in the key tab was
indeed correct... That lib code is definitely lacking when it comes
to debug-ability... :-(

So buyer bewared... if you recently installed F-10 please check to see
if your /etc/hosts file only contains the non-FQDN host name on the
127.0.0.1 line. 

Details are at: https://bugzilla.redhat.com/show_bug.cgi?id=474086

steved.

