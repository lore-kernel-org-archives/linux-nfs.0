From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: mountd: empty export list should not be treated
 as a failure
Date: Tue, 12 Feb 2008 16:17:33 -0500
Message-ID: <47B20CED.3050407@RedHat.com>
References: <1202793191.2890.36.camel@serendib.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Harshula <harshula@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758875AbYBLVRg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 16:17:36 -0500
In-Reply-To: <1202793191.2890.36.camel-2WabGjdRN2LRvmHwrWB8BmjR7Gm6iKkz0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Harshula wrote:
> In mountd, if get_exportlist() (utils/mountd/mountd.c) returns NULL it
> should not be considered a failure. It just means that there are no
> exports on the system.
> 
> The practical problem with the current code is that a showmount -e
> results in a syslog message from mountd that looks like:
> 
> rpc.mountd: export request from 10.250.100.2 failed.
Committed... thanks!

steved.
