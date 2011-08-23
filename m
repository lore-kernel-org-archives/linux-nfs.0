Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38264 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275Ab1HWAYx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 20:24:53 -0400
Date: Tue, 23 Aug 2011 10:24:44 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: wow
Message-ID: <20110823102444.2bc6d1c7@notabene.brown>
In-Reply-To: <CCE4A253-3046-45EA-92E2-1C384AC64917@oracle.com>
References: <CCE4A253-3046-45EA-92E2-1C384AC64917@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 22 Aug 2011 15:15:06 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:

> http://www.linuxjournal.com/content/how-release-stuck-nfs-mounts-without-reboot
> 

That brings back memories...  I've definitely had a case where I added a
an extra IP address to some server so it could pretend to be a dead serve and
allow the mount points to fail and processes to be killed.

With lazy unmounts and TASK_KILLABLE that should all be a think of the past
though ... I hope.

NeilBrown
