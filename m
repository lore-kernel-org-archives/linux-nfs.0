Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f180.google.com ([209.85.212.180]:61426 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062AbaKMT0V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Nov 2014 14:26:21 -0500
Received: by mail-wi0-f180.google.com with SMTP id hi2so560093wib.13
        for <linux-nfs@vger.kernel.org>; Thu, 13 Nov 2014 11:26:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141113190213.GA28516@fieldses.org>
References: <5463787A.7080404@RedHat.com>
	<CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com>
	<43A888DD-6114-48FC-AE99-DBE6BBF19A7B@oracle.com>
	<5463A282.8060803@RedHat.com>
	<CAHQdGtTV_XW94GTeyFh+jMQ8EzkuTHv9dF+V0KMO+pqYMT3yrw@mail.gmail.com>
	<5463C066.8030205@Netapp.com>
	<5463C3F8.50004@RedHat.com>
	<CAHQdGtSnz84ymSC0n=vb5yMPj+ZfgJw=PMeDOhpvQHPwK+eq3A@mail.gmail.com>
	<5464F10D.3010402@RedHat.com>
	<CAHQdGtTqJDBTKZ3e9u3FgRjRbTFapEh+nYi0i+yy02Dar-ypPA@mail.gmail.com>
	<20141113190213.GA28516@fieldses.org>
Date: Thu, 13 Nov 2014 14:26:20 -0500
Message-ID: <CAHQdGtR-e2vqZKZa0yy8tcwShyqJ-m-pVNxSzej8WApbEfTtcg@mail.gmail.com>
Subject: Re: mount default minor version behavior
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 13, 2014 at 2:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Nov 13, 2014 at 01:52:09PM -0500, Trond Myklebust wrote:
>> On Thu, Nov 13, 2014 at 12:57 PM, Steve Dickson <SteveD@redhat.com> wrote:
>> > On 11/12/2014 05:42 PM, Trond Myklebust wrote:
>> >>>> NFS v4.0, 4.1, and 4.2 are all part of the same module, though.  Is there a way to analyze modules and determine what is compiled in?
>> >>> > Maybe come up with some global bit field could be used?
>> >>> > Each bit signifies a minor version is enabled...
>> >>> >
>> >> No. This means that mount.nfs now suddenly needs to know the names of
>> >> the NFS modules and how to load them before it calls mount() just so
>> >> that it knows which parameters to try. This is a rathole we don't want
>> >> to explore...
>> > I don't think mount.nfs needs to know any names... Just
>> > a file /proc/fs/nfs/mount that tells mount.nfs where
>> > to start the negotiation....
>> >
>>
>> The kernel does not have that information until the NFSv4 module is loaded.
>
> I still don't get it.  All it needs to know is an upper bound--that
> could be a single compile-time constant.  Is there any reason not to
> build that number into the main nfs module?
>

Firstly, the main nfs module isn't preloaded either.

Secondly, that's a layering violation. The main nfs module has no
business knowing anything about the sub-modules other than how to load
them when needed. If I want to recompile my NFSv4 module to add
NFSv4.2 support, then I shouldn't have to recompile the entire
contents of my nfs directory.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
