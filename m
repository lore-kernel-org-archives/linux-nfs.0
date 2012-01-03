Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out02.mta.xmission.com ([166.70.13.232]:47392 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041Ab2ACDqz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jan 2012 22:46:55 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust\@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>,
        "neilb\@suse.de" <neilb@suse.de>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields\@fieldses.org" <bfields@fieldses.org>,
        "davem\@davemloft.net" <davem@davemloft.net>,
        "devel\@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 01/11] SYSCTL: export root and set handling routines
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
	<20111214104449.3991.61989.stgit@localhost6.localdomain6>
	<m1bor6rg39.fsf@fess.ebiederm.org> <4EEEFC54.10700@parallels.com>
	<m18vm8g951.fsf@fess.ebiederm.org> <4EEF2C9A.8000403@parallels.com>
	<m1pqfkecw0.fsf@fess.ebiederm.org> <4EEF7364.8000407@parallels.com>
Date: Mon, 02 Jan 2012 19:49:00 -0800
In-Reply-To: <4EEF7364.8000407@parallels.com> (Stanislav Kinsbursky's message
	of "Mon, 19 Dec 2011 21:24:52 +0400")
Message-ID: <m1vcotigyb.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Stanislav Kinsbursky <skinsbursky@parallels.com> writes:

> 19.12.2011 20:37, Eric W. Biederman пишет:
>> Stanislav Kinsbursky<skinsbursky@parallels.com>  writes:
>>
>> Doing that independently of the rest of the sysctls is pretty horrible
>> and confusing to users.   What I am planning might suit your needs and
>> if not we need to talk some more about how to get the vfs to do
>> something reasonable.
>>
>
> Ok, Eric. Would be glad to discuss your sysctls plans.
> But actually you already know my needs: I would like to make sysctls work in the
> way like sysfs does: i.e. content of files depends on mount maker -
> not viewer.

What drives the desire to have sysctls depend on the mount maker?
Especially what drives that desire not to have it have a /proc/<pid>/sys
directory that reflects the sysctls for a given process.

Eric

