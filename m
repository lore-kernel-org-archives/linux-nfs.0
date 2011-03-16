Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65398 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755643Ab1CPVkU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 17:40:20 -0400
Subject: Re: how to verify file delegations
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jimmy Dorff <jdorff@phy.duke.edu>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4D812388.5020304@phy.duke.edu>
References: <4D812388.5020304@phy.duke.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Mar 2011 17:40:19 -0400
Message-ID: <1300311619.30551.14.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-16 at 16:54 -0400, Jimmy Dorff wrote:
> Hi,
> 
> I'm a sysadmin doing some testing with NFSv4 on RHEL6/Fedora 14. How can 
> I verify that file read and write delegations are occurring ? The 
> "delegpurge" and "delegreturn" values are zero from nfsstat.

If delegreturn is pinned at zero, then you are highly unlikely to be
using delegations at all. Have you checked that the callback channel is
set to a port that the server can connect to?

You can pin the callback channel to a particular port (in this example
port 4048) using something like the following on the NFS client:

echo "options nfs callback_tcpport=4048" >> /etc/modprobe.d/options-local.conf

then edit your NFS client firewall settings to allow incoming TCP
connections to that port. Finally, you'll want to reboot that client...

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

