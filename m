Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753728Ab2ACO6G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jan 2012 09:58:06 -0500
Message-ID: <4F03177C.1070803@RedHat.com>
Date: Tue, 03 Jan 2012 09:58:04 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RFC: rpcbind start/stop scripts affects all nested pid namespaces
References: <4EF86DAF.9040804@parallels.com>
In-Reply-To: <4EF86DAF.9040804@parallels.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please note, the systemV init scripts are  being replaced with 
systemd scripts, at least with Fedora 16 and beyond...

See /lib/systemd/system/rpcbind.service on Fedora 16 for
the new way rpcbind is started...

steved.

On 12/26/2011 07:50 AM, Stanislav Kinsbursky wrote:
> When trying to start and stop rpcbind in different pid namespaces I've noticed, that rpcbind stop command kills all rpcbind processes in nested pid namespaces.
> This is caused by "/sbin/pidof rpcbind" call on rpcbind start. IOW file "/var/run/rpcbind.pid" contains pids of all nested rpcbind processes.
> The simplest solution I see for now is to add "-c" options to "pidof" command. But I'm not sure about quality of solution and probably "killall5" have to be updated with new option to work only in current pid namespace.
> Would be glad to hear any opinion about this problem.
> 
