Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f173.google.com ([209.85.212.173]:39573 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906AbaKMSwK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Nov 2014 13:52:10 -0500
Received: by mail-wi0-f173.google.com with SMTP id n3so431915wiv.6
        for <linux-nfs@vger.kernel.org>; Thu, 13 Nov 2014 10:52:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5464F10D.3010402@RedHat.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
	<CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>
	<5462608B.1090607@RedHat.com>
	<CAHQdGtQtQaGYsnaf+rVpNfkSRK97AEMU=2-Yx+GtwGXgNHcf1w@mail.gmail.com>
	<54635BB5.1020702@RedHat.com>
	<CAHQdGtSPLdUGNTcjC3-vaHEY7nE4tGq=f9eRNyBx57czJc_m4A@mail.gmail.com>
	<5463787A.7080404@RedHat.com>
	<CAHQdGtSwgyrBzc9iOmPLCd+k3Y9c2QeAFJdks4OBrXZfpiatCA@mail.gmail.com>
	<43A888DD-6114-48FC-AE99-DBE6BBF19A7B@oracle.com>
	<5463A282.8060803@RedHat.com>
	<CAHQdGtTV_XW94GTeyFh+jMQ8EzkuTHv9dF+V0KMO+pqYMT3yrw@mail.gmail.com>
	<5463C066.8030205@Netapp.com>
	<5463C3F8.50004@RedHat.com>
	<CAHQdGtSnz84ymSC0n=vb5yMPj+ZfgJw=PMeDOhpvQHPwK+eq3A@mail.gmail.com>
	<5464F10D.3010402@RedHat.com>
Date: Thu, 13 Nov 2014 13:52:09 -0500
Message-ID: <CAHQdGtTqJDBTKZ3e9u3FgRjRbTFapEh+nYi0i+yy02Dar-ypPA@mail.gmail.com>
Subject: Re: mount default minor version behavior
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 13, 2014 at 12:57 PM, Steve Dickson <SteveD@redhat.com> wrote:
> On 11/12/2014 05:42 PM, Trond Myklebust wrote:
>>>> NFS v4.0, 4.1, and 4.2 are all part of the same module, though.  Is there a way to analyze modules and determine what is compiled in?
>>> > Maybe come up with some global bit field could be used?
>>> > Each bit signifies a minor version is enabled...
>>> >
>> No. This means that mount.nfs now suddenly needs to know the names of
>> the NFS modules and how to load them before it calls mount() just so
>> that it knows which parameters to try. This is a rathole we don't want
>> to explore...
> I don't think mount.nfs needs to know any names... Just
> a file /proc/fs/nfs/mount that tells mount.nfs where
> to start the negotiation....
>

The kernel does not have that information until the NFSv4 module is loaded.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
