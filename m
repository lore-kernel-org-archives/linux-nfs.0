Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38038 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755719AbbHQPk7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 11:40:59 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: nfs-utils regression on IPv6-less kernels
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150817124220.GA17877@infradead.org>
Date: Mon, 17 Aug 2015 08:40:25 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F810C54A-A075-40D1-9912-80A85A7A0D63@oracle.com>
References: <20150810131358.GA19466@infradead.org> <55C9D2F2.1020300@RedHat.com> <20150817124220.GA17877@infradead.org>
To: Christoph Hellwig <hch@infradead.org>, Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 17, 2015, at 5:42 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Aug 11, 2015 at 06:48:18AM -0400, Steve Dickson wrote:
>> hmm... What do you mean "fails to start"...  are there any error messages?
> 
> [....] Starting NFS kernel daemon: nfsdrpc.nfsd: address family AF_INET6
> not supported by protocol TCP
> rpc.nfsd: unable to set any sockets for nfsd
> failed!
> 
> And then any attempts to mount from this machine fail.
> 
>> If nfs-utils is compiled with the --disable_ipv6 flag, does
>> the same problem happen?
> 
> No, that fixes it.

Probably stopped working with "rpc.nfsd: Squelch DNS errors when
using --host option".

getaddrinfo(3) returns a list of addresses, some of which are
IPv6 addresses. It gets the list from /etc/hosts, or DNS. Even
on kernels which do not support IPv6, there may be at least one
IPv6 address in the list.

nfssvc_setfds() then loops over this list. The error handling
in nfssvc_setfds() causes the loop to exit if the socket(2)
call fails. It should "continue" if the error is EAFNOSUPPORT.
In fact, that xlog notice can also be removed.

I'm traveling this week. Is this enough for you to generate a
fix?


--
Chuck Lever



