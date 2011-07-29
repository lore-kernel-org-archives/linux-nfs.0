Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60009 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751292Ab1G2RL2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 13:11:28 -0400
Date: Fri, 29 Jul 2011 13:11:27 -0400
To: Frank van Maarseveen <frankvm@frankvm.com>
Cc: linux-nfs@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
        jlayton@redhat.com
Subject: Re: [NLM] support for a per-mount grace period.
Message-ID: <20110729171126.GN23194@fieldses.org>
References: <1311878660-24482-1-git-send-email-frankvm@frankvm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311878660-24482-1-git-send-email-frankvm@frankvm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 28, 2011 at 08:44:18PM +0200, Frank van Maarseveen wrote:
> The following two patches implement support for a per-mount NLM
> grace period. The first patch is a minor cleanup which pushes
> down locks_in_grace() calls into functions shared by NFS[234]. Two
> locks_in_grace() tests have been reordered to avoid duplicate calls at
> run-time (assuming gcc is smart enough). nlmsvc_grace_period is now a
> function instead of an unused variable.
> 
> The second patch is the actual implementation. It is currently in use for
> a number of NFSv3 virtual servers on one physical machine running 2.6.39.3
> where the virtualization is based on using different IPv4 addresses.

Thanks, that is something we'd like to have working well.

Off the top of my head:
	- Do you have a plan for dealing with NFSv4?
	- Do you need any more kernel changes to get this working?
	- What about userspace changes?
	- Do you support migrating/failing over virtual nfs service
	  between machines, and if so, how are you doing it?

I've also been trying to work out whether it would be cleaner to do this
sort of thing by building on top of Pavel Emelyanov's container
work--cc'd.

(Obnoxious of me, because I know he's working on something else right
now, but perhaps he won't mind setting this email aside for now and
responding when he gets some time back....)

--b.
