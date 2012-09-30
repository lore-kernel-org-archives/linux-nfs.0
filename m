Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f46.google.com ([209.85.210.46]:46690 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637Ab2I3VXu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Sep 2012 17:23:50 -0400
Date: Sun, 30 Sep 2012 14:23:41 -0700
From: Jonathan Nieder <jrnieder@gmail.com>
To: Chris Hiestand <chiestand@salk.edu>
Cc: Ben Hutchings <ben@decadent.org.uk>, 669314@bugs.debian.org,
        viro@zeniv.linux.org.uk, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Micheal Waltz <mwaltz@qualcomm.com>,
        Gabriel Evanoff <gevanoff@salk.edu>
Subject: Re: NFS: kernel forces trailing slash for export in /proc/self/mounts
Message-ID: <20120930212341.GA32505@elie.Belkin>
References: <8F8193BD-84C6-4905-8789-DE7EB2579A4E@salk.edu>
 <1347762073.13258.188.camel@deadeye.wl.decadent.org.uk>
 <254E1AAA-BDE2-41A8-94D8-6E677860AD72@salk.edu>
 <1347804028.13258.267.camel@deadeye.wl.decadent.org.uk>
 <FB3CAE84-FDFE-4345-9F54-3295BDE2AD81@salk.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <FB3CAE84-FDFE-4345-9F54-3295BDE2AD81@salk.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chris,

Chris Hiestand wrote:
> On Sep 16, 2012, at 7:00 AM, Ben Hutchings wrote:

>> This was my first thought - but what if userland provides a device name
>> with a slash on the end?  I think we have to report it back with the
>> slash in that case.
[...]
> As a point of comparison, matching the given input is the behavior of 2.6.32-5 in Debian Squeeze.
> So I think your approach is better.

Thanks for looking it over.  Did you get a chance to test Ben's patch?

Curious,
Jonathan
