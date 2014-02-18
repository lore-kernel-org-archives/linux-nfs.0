Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015AbaBRVOu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Feb 2014 16:14:50 -0500
Message-ID: <5303CD45.1010208@RedHat.com>
Date: Tue, 18 Feb 2014 16:14:45 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] nfs-utils: systemd units bug fixes and comments.
References: <1392713329-17979-1-git-send-email-steved@redhat.com> <FB361B21-041C-484F-815E-E4A90C3DAE06@oracle.com> <5303AA1D.3020705@RedHat.com> <C4E26F58-0097-4200-9860-8F8B8172B627@oracle.com>
In-Reply-To: <C4E26F58-0097-4200-9860-8F8B8172B627@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/18/2014 02:36 PM, Chuck Lever wrote:
>> At this point its a pipe dream for rpc.gssd to run with no keytab.
> This is not a pipe dream. 
I meant its a pipe dream in the current state due to, your nicely 
termed, "gssd log diarrhea" ;-) 

steved.
 
> I’m talking about the common use case where a user kinit’s as root then uses the “-n” option on gssd so that root’s credential is used as the client’s machine credential, instead of using the keytab to establish a GSS context.
> 
> With the exception of kernels 3.9 - 3.12, this has always worked, does require gssd to be running, and does not need to have a keytab on the client to operate correctly.  When 3.9 broke this feature, people (including NeilB!) complained loudly.
> 
>> > It logs a ton of errors messages on every upcall which means 
>> > on every mount these days.
>> > We either have to tone down the error messages or check for the 
>> > existence of the keytab before processing the upcall.
>> > I think the latter would better… 
> gssd default verbosity is a legacy of the days when Kerberized NFS was new and we wanted verbose logging to monitor gssd activity.  It seems like a harmless step forward to eliminate them or hide some or all of them behind a gssd command line option.
> 
> The bug here is gssd log diarrhea.
