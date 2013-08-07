Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport02-1.csupomona.edu ([134.71.187.45]:8203 "EHLO
	ironport02-1.csupomona.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756833Ab3HGCx2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Aug 2013 22:53:28 -0400
Date: Tue, 6 Aug 2013 19:53:27 -0700
From: Brian De Wolf <bldewolf@csupomona.edu>
To: Bryan Schumaker <bjschuma@gmail.com>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: NFS uses wrong domain in SETATTR
Message-ID: <20130806195327.71323541@csupomona.edu>
In-Reply-To: <52015795.9060003@gmail.com>
References: <20130718174155.0f189280@csupomona.edu>
	<52015795.9060003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 6 Aug 2013 13:07:49 -0700
Bryan Schumaker <bjschuma@gmail.com> wrote:

> Hi Brian,
> 
> I'm sorry it took so long to reply to you, but you haven't been
> forgotten!  I've set up kerberos using freeipa on my own test system
> but I haven't been able to reproduce the bug you're seeing.  I had it
> working by using my kerberos domain set in /etc/idmap.conf and I saw
> the new domain go over the wire when I changed it in idmap.conf.  Do
> I need to do anything more to mimic your setup?
> 

Thanks for responding!  It seems like DNS might be where the wrong
kerberos domain is coming from.  Is your test client in the same domain
as your kerberos realm?  My clients aren't, and the subdomain they're
in is what is sent in the NFS requests.

I was able to test this by preferring files for hosts in nsswitch.conf
and overriding the host's name in /etc/hosts.  Normally the host is
under unx.csupomona.edu.  Moving the host to csupomona.edu in hosts
(and rebooting) causes chgrp to start working.  When I revert the
nsswitch and hosts changes chgrp keeps working until another reboot.

I hope this helps you reproduce this issue.  Let me know if there is
any other information you need.
