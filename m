Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3.conversis.de ([213.203.208.210]:38527 "EHLO
	mail3.conversis.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756318AbbFRSHg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 14:07:36 -0400
Message-ID: <558308E6.2040802@conversis.de>
Date: Thu, 18 Jun 2015 20:07:34 +0200
From: Dennis Jacobfeuerborn <dennisml@conversis.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS server startup hangs for 60 seconds
References: <5582B009.9090901@conversis.de> <20150618180141.GA21212@fieldses.org>
In-Reply-To: <20150618180141.GA21212@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18.06.2015 20:01, J. Bruce Fields wrote:
> On Thu, Jun 18, 2015 at 01:48:25PM +0200, Dennis Jacobfeuerborn wrote:
>> Hi,
>> when I start nfs-server.service on a CentOS 7 system it takes 60 seconds
>> until the nfsd finally is up.
> 
> How exactly are you testing that?  (What are you using to decide when
> nfsd is up?)
> 

The nfsd processes show up in the ps output.

After some digging I finally found that the reason for this is a buggy
systemd unit file in RHEL/CentOS 7.

This is a bug in nfs-server.service and he fix is to copy
nfs-server.service to /etc/systemd/system and replace all occurrences of
"rpcbind.target" with "rpcbind.service".

See this bug for reference:
https://bugzilla.redhat.com/show_bug.cgi?id=1171603

Regards,
 Dennis

