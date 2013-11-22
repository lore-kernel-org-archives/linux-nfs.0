Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:32832 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278Ab3KVV2s convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Nov 2013 16:28:48 -0500
Received: by mail-ie0-f182.google.com with SMTP id as1so3056003iec.41
        for <linux-nfs@vger.kernel.org>; Fri, 22 Nov 2013 13:28:48 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to sync Kerberos credentials and kernel gss_contexts.
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <1385147500.3912.68.camel@willson.li.ssimo.org>
Date: Fri, 22 Nov 2013 16:28:45 -0500
Cc: Steve Dickson <SteveD@redhat.com>,
        Andy Adamson <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3ABF556D-FA65-4A9E-9880-5AA5ADF80F55@gmail.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com> <1382454148.9794.72.camel@willson.li.ssimo.org> <A8A66580-CD6F-4141-AE93-B1DD025BFD7A@netapp.com> <1382458162.9794.85.camel@willson.li.ssimo.org> <9C15298B-8915-46E2-85E1-5098F1A12832@netapp.com> <1382462720.9794.131.camel@willson.li.ssimo.org> <096F13FC-A99E-4C19-ACCA-01C244D7420F@netapp.com> <1384980587.17044.49.camel@willson.li.ssimo.org> <528E0C8A.9070608@RedHat.com> <1385147500.3912.68.camel@willson.li.ssimo.org>
To: Simo Sorce <simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 22, 2013, at 14:11, Simo Sorce <simo@redhat.com> wrote:

> On Thu, 2013-11-21 at 08:37 -0500, Steve Dickson wrote:
>> 
>> On 20/11/13 15:49, Simo Sorce wrote:
>>>> I think Solution 3: [nfslog/nfslogout interfaces invoked from PAM or
>>>>> other login system facility] is a good way to go.  Note that a PAM
>>>>> based solution where in the PAM would get us most of the way towards
>>>>> providing users with a way to login and logout of NFS kerberized
>>>>> shares.
>>>>> 
>>>>> Comments on an NFS PAM that will destroy GSS context for a UID upon
>>>>> logout?
>>> I prefer 3 too, let it to the login system (whether PAM based or other)
>>> to determine when it is time to destroy credentials, that's the only
>>> component that have a chance of guessing right.

Really? How do you deal with backgrounded tasks?

>>> Of course you could also provide a user utility to force a purge.
>>> 
>> +1 for me on this options as well... 
>> 
>> But how is it known when somebody logs out? Is that PAM-able as well?
> 
> I would say "login process" more than pam, but the basic idea is the
> same, a user space program that knows when the user is logging out for
> good and is privileged enough to go an tell the kernel to nuke creds.

What’s such a process going to use as an indicator that the user is “logging out for good”?

Trond