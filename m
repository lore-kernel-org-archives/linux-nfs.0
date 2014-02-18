Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751242AbaBRSov (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Feb 2014 13:44:51 -0500
Message-ID: <5303AA1D.3020705@RedHat.com>
Date: Tue, 18 Feb 2014 13:44:45 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] nfs-utils: systemd units bug fixes and comments.
References: <1392713329-17979-1-git-send-email-steved@redhat.com> <FB361B21-041C-484F-815E-E4A90C3DAE06@oracle.com>
In-Reply-To: <FB361B21-041C-484F-815E-E4A90C3DAE06@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/18/2014 09:29 AM, Chuck Lever wrote:
> On Feb 18, 2014, at 3:48 AM, Steve Dickson <SteveD@redhat.com> wrote:
> 
>> > Bug Fixes:
>> > 
>> > The /proc/net/rpc/use-gss-proxy file can not be used
>> > as a start up trigger for rpc.svcsgssd since it always
>> > exists, with or without gss-proxy installed.
>> > 
>> > Adding the Wants= to the nfs server unit cause a systemd ordering 
>> > cycle which caused reboots to take forever.
>> > 
>> > Comment One:
>> > 
>> > Even though nfs-client does conditionally start the rpc.gssd 
>> > service when /etc/krb5.keytab exists (which good),
> No, that's bad.  rpc.gssd has to run in cases where there is no /etc/krb5.ktab.  See
> 
>  http://www.spinics.net/lists/linux-nfs/msg41585.html
At this point its a pipe dream for rpc.gssd to run with no keytab.
It logs a ton of errors messages on every upcall which means 
on every mount these days. 

We either have to tone down the error messages or check for the 
existence of the keytab before processing the upcall.
I think the latter would better... 

> 
> The existence of /etc/krb5.conf is a better choice.
> 
Fine... If there is no objection... I'm ok with it..

steved.
