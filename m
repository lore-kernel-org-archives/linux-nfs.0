Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sender1.zohomail.com ([72.5.230.103]:40014 "EHLO
	sender1.zohomail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbbAQM1s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Jan 2015 07:27:48 -0500
Message-ID: <54BA4D44.9060303@zoho.com>
Date: Sat, 17 Jan 2015 12:53:40 +0100
From: Ralph Zack <ralphz@zoho.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Secure NFSv4 mounts and daemons
References: <54B6F7C1.5040208@zoho.com> <m9akb5$ig3$1@ger.gmane.org> <alpine.OSX.2.19.9992.1501161628010.498@planck.local>
In-Reply-To: <alpine.OSX.2.19.9992.1501161628010.498@planck.local>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/16/2015 10:36 PM, Benjamin Coddington wrote:
> Wow, looks like kinit /will/ read your password from stdin.  I had no idea.
> 
> I've done this with a keytab and cron job running as the
> service's user to keep the credential caches for the service's user fresh.
> Kinit should be something like `kinit -kt /keyab/file batch/host@realm.com`
> Run your jobs more frequently than the ticket expiry time and everything
> should be fine.


That is pretty much what I had in mind if there was no better solution.
It just seemed bit hacky to me and I thought there was maybe a more
elegant solution, but I may end up doing it like that.

On 01/17/2015 12:11 AM, Anthony Messina wrote:
> I use GSS-Proxy for this:
> https://fedorahosted.org/gss-proxy/
>

That looks very interesting at first glance, I'll have a closer look at
it. Thanks!

- Ralph

