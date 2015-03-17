Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932366AbbCQWfd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 18:35:33 -0400
Message-ID: <5508AC34.3030508@RedHat.com>
Date: Tue, 17 Mar 2015 18:35:32 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Rupert Dance <rsdance@soft-forge.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Connectathon Issues
References: <009501d060e6$b54c3780$1fe4a680$@soft-forge.com>
In-Reply-To: <009501d060e6$b54c3780$1fe4a680$@soft-forge.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/17/2015 03:15 PM, Rupert Dance wrote:
> Nroff
> 
> ./stat: no data in nroff.time
I believe this has to do with the format of time 'time' command.
stat.c expects a particular date format that changes whether 
/usr/bin/time is used or the shell version of data. 

try adding TIME=/usr/bin/time to the top of general/runtests.wrk

steved.
