Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:35922 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbbFHOmL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 10:42:11 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] rpc.nfsd: add no-ipv4 and no-ipv6 options
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <d4bfa4c82f2a8ef2dec4dce303c0c96b@mail.sessys.com>
Date: Mon, 8 Jun 2015 10:45:00 -0400
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org
Message-Id: <AA024850-47EF-40EB-A312-D2490D6FCEC5@gmail.com>
References: <55743EDE.7070707@gmail.com> <3CE6594A-508B-4BBD-9E52-CF9EDDA6274D@oracle.com> <557597D3.8090401@gmail.com> <312511264c19c5a98cbd1062531b306e@mail.sessys.com> <2F03891D-9240-4A8E-BEEB-7F5BBAD1B5FE@gmail.com> <76DB6DF0-8409-4D42-B2FD-6C7B08B148A5@gmail.com> <d4bfa4c82f2a8ef2dec4dce303c0c96b@mail.sessys.com>
To: Sean Elble <elbles@sessys.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 8, 2015, at 10:33 AM, Sean Elble <elbles@sessys.com> wrote:

> On 08.06.2015 10:27, Chuck Lever wrote:
>>> I don’t understand the need to “turn off” an address family. That’s what
>>> /etc/netconfig is supposed to be for. What’s not happening here that
>>> should be?
>> What I mean is: I’d rather not add more command line options if there
>> is a way for rpc.nfsd to automatically and quietly do what is needed.
>> But I don’t understand the use case here. Sean, can you explain it for
>> bears of little brain?
> 
> Sure, and please correct me if any of my understanding is incorrect (as it may well be).  In my environment, I wanted to have NFS only listen on one interface of a multihomed host.  In using the "--host" parameter to do so, I saw the error message regarding IPv6 thrown.

OK, yes I read that last week, and had just forgotten it. That sounds to
me like - - host is broken (or, at least noisier than it should be in this
case).

Do you provide an IP address or a hostname when specifying - - host?

> While disabling IPv6 globally in /etc/netconfig is an option (one I understand to be "global", in that it'd affect *all* applications on the host), it'd be nice to disable IPv6 for a single service/daemon instead.
> 
> Of course, the fact that at least Ubuntu and RHEL (and almost certainly their upstream and their derivatives, respectively) relay the error message when running the NFS init scripts could confuse someone into thinking NFS failed to start properly (until they look at the output of netstat -nalp, etc.).  I'd almost argue that's a larger concern. By the same token, "--host" seems a little used option, for whatever reason.
> 
> In any case, I'm the little brained one in this group.  :-)

--
Chuck Lever
chucklever@gmail.com



