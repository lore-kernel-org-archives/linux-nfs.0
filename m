Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25268 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab0GWPPa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jul 2010 11:15:30 -0400
Message-ID: <4C49B1AD.3060302@oracle.com>
Date: Fri, 23 Jul 2010 11:13:49 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Lennart Poettering <lennart@poettering.net>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
References: <20100719021906.GA16939@tango.0pointer.de> <4C4734DC.9010106@oracle.com> <20100721215640.GA5648@tango.0pointer.de>
In-Reply-To: <20100721215640.GA5648@tango.0pointer.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Lennart-

On 07/21/10 05:56 PM, Lennart Poettering wrote:
> On Wed, 21.07.10 13:56, Chuck Lever (chuck.lever@oracle.com) wrote:
>
>> Why aren't sd-daemon.[ch] part of a systemd related library?  They
>> seem pretty generic to me, and could be useful for other daemons.
>
> Well, these two files are simply a reference implementation. The
> algorithms are as trivial as they can get. For now we decided to simply
> ask people to include the ref impl in their sources. Either the .c/.h
> file or just the function needed. This is usually easier to get accepted
> politically since this will then not add a new dependency to the
> packages. Maybe one day when the number of APIs we provide are
> substantial enough and the algorithms not trivial anymore we will add a
> real library for this.
>
> But for now, if people just add this tiny bit of code to their sources
> this will be a feature that finds it way silently into the various
> packages without requiring any new dependencies, and people will hence
> have little reason to disable it.

The complexity or size of the systemd code is not the issue, it is how 
it will be maintained going forward.  Especially since these are all 
system daemons, you know that there will be security bug fixes.  The 
current situation means every daemon will have to be rebuilt and 
redistributed to fix a bug in the systemd code.  It also creates inertia 
to fixing problems, thus inviting the individual snippets in each daemon 
to become hacked up and out of date.

The least you could do is provide both the raw source files and a 
library implementation, and let daemon maintainers choose which they 
prefer.  The best solution would provide a clean versioned C language 
API via a shared library

Do you have some picture of systemd adoption outside of Fedora?
