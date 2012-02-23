Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:49504 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755227Ab2BWOQY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 09:16:24 -0500
Received: from [192.168.23.207] (dsl254-070-154.nyc1.dsl.speakeasy.net [216.254.70.154])
	by che.mayfirst.org (Postfix) with ESMTPSA id 8CDCDF970
	for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2012 09:16:20 -0500 (EST)
Message-ID: <4F464A4A.10403@fifthhorseman.net>
Date: Thu, 23 Feb 2012 09:16:42 -0500
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Reply-To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 client restriction
References: <CAO9xhuZ+2VsTog1bqomC82jVfNFVOx6JTGgG+muDQsFu_5R7ZA@mail.gmail.com> <20120223010111.GA19432@fieldses.org> <4F45E63B.9090608@steve-ss.com>
In-Reply-To: <4F45E63B.9090608@steve-ss.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/23/2012 02:09 AM, steve wrote:
> It is not recommended to use the pseudoroot fsid=0 stuff for Linux.
> 
> See the nfs wiki: 'The linux implementation allows you to designate a
> real filesystem as the pseudofilesystem, identifying that export with
> the fsid=0 option; we no longer recommend this. Instead, on any recent
> linux distribution, just list exports in /etc/exports exactly as you
> would for NFSv2 or NFSv3.'

I believe the last time this came up, i asked for a rationale or
explanation.  The only reason given [0] was from J. Bruce Fields:

>> The main problem with the fsid=0 trick is that your v3 and v4 clients
>> end up with different paths.

So, if you have no v3 clients, i don't think there is any reason to
avoid fsid=0 if it makes things cleaner for you.  And removing fsid=0
will require you to change /etc/fstab (or your automounter config) in
all of your clients.

	--dkg

[0] http://thread.gmane.org/gmane.linux.nfs/46932/focus=46944
