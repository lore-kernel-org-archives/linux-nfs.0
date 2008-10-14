From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: file open for write fails under stress
Date: Tue, 14 Oct 2008 10:10:59 -0400
Message-ID: <1223993459.8907.11.camel@localhost>
References: <48F3D106.9020203@yadan.net> <1223990637.8907.3.camel@localhost>
	 <48F4A381.4040700@yadan.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Omry Yadan <omry-FZzTFxfWWV5eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:48945 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880AbYJNOLE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Oct 2008 10:11:04 -0400
In-Reply-To: <48F4A381.4040700-FZzTFxfWWV5eoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-10-14 at 15:49 +0200, Omry Yadan wrote:
> Trond Myklebust wrote:
> 
> > On Tue, 2008-10-14 at 00:51 +0200, Omry Yadan wrote:
> >   
> >> I have an application that open many files for writing very fast, in a
> >> way - it can almost be looked as a file system stress test.
> >>
> >>
> >> my application is single threaded, and I noticed the following problem
> >> when running a single instance of it:
> >>
> >>
> >> at some point, after opening (and closing) many files for writing, the
> >> application fails to open a file for writing.
> >>
> >> if I sleep for 1 second and try again, it works.
> >>     
> >
> > What version of nfs, filesystem on the server, export options, mount
> > options,...?
> >
> >   
> 
> /etc/exports:
> /var/vizi 38.99.126.160/28(rw,sync,no_subtree_check)
> server file system : ext3 on a raid5 (900gb, 3x500gb hd).
> server nfs version: 1.0.10

> client mount:
> nas1:/var/vizi on /var/vizi type nfs (rw,tcp,addr=38.99.126.163)

So I assume it is NFS version 3, then?

What error does the application get when the open() fails?

Cheers
  Trond

