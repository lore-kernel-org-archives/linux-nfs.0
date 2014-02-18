Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:50304 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbaBRTgo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Feb 2014 14:36:44 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 0/2] nfs-utils: systemd units bug fixes and comments.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5303AA1D.3020705@RedHat.com>
Date: Tue, 18 Feb 2014 14:36:38 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C4E26F58-0097-4200-9860-8F8B8172B627@oracle.com>
References: <1392713329-17979-1-git-send-email-steved@redhat.com> <FB361B21-041C-484F-815E-E4A90C3DAE06@oracle.com> <5303AA1D.3020705@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

On Feb 18, 2014, at 1:44 PM, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 02/18/2014 09:29 AM, Chuck Lever wrote:
>> On Feb 18, 2014, at 3:48 AM, Steve Dickson <SteveD@redhat.com> wrote:
>> 
>>>> Bug Fixes:
>>>> 
>>>> The /proc/net/rpc/use-gss-proxy file can not be used
>>>> as a start up trigger for rpc.svcsgssd since it always
>>>> exists, with or without gss-proxy installed.
>>>> 
>>>> Adding the Wants= to the nfs server unit cause a systemd ordering 
>>>> cycle which caused reboots to take forever.
>>>> 
>>>> Comment One:
>>>> 
>>>> Even though nfs-client does conditionally start the rpc.gssd 
>>>> service when /etc/krb5.keytab exists (which good),
>> No, that's bad.  rpc.gssd has to run in cases where there is no /etc/krb5.ktab.  See
>> 
>> http://www.spinics.net/lists/linux-nfs/msg41585.html
> At this point its a pipe dream for rpc.gssd to run with no keytab.

This is not a pipe dream.  I’m talking about the common use case where a user kinit’s as root then uses the “-n” option on gssd so that root’s credential is used as the client’s machine credential, instead of using the keytab to establish a GSS context.

With the exception of kernels 3.9 - 3.12, this has always worked, does require gssd to be running, and does not need to have a keytab on the client to operate correctly.  When 3.9 broke this feature, people (including NeilB!) complained loudly.

> It logs a ton of errors messages on every upcall which means 
> on every mount these days.
> We either have to tone down the error messages or check for the 
> existence of the keytab before processing the upcall.
> I think the latter would better… 

gssd default verbosity is a legacy of the days when Kerberized NFS was new and we wanted verbose logging to monitor gssd activity.  It seems like a harmless step forward to eliminate them or hide some or all of them behind a gssd command line option.

The bug here is gssd log diarrhea.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



