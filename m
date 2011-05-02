Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3933 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963Ab1EBWCp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 18:02:45 -0400
Subject: Re: How does NFS handle notify?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stef Bon <stefbon@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
In-Reply-To: <BANLkTimB=-QaW8S-H9XNv9TM+gWbB23CjQ@mail.gmail.com>
References: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
	 <20110502140750.GA10885@fieldses.org>
	 <BANLkTinTu8XVmxkUUhJby8=DNY4sZF5VAQ@mail.gmail.com>
	 <1304347155.7830.7.camel@lade.trondhjem.org>
	 <BANLkTikZnnt0cmpP4iT4Q4EJTxZnSC_SYQ@mail.gmail.com>
	 <1304356699.7830.26.camel@lade.trondhjem.org>
	 <BANLkTi=2uYagwN=Xy9FxhXV4wt3tf669JA@mail.gmail.com>
	 <1304367673.20876.1.camel@lade.trondhjem.org>
	 <BANLkTimB=-QaW8S-H9XNv9TM+gWbB23CjQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 02 May 2011 18:02:44 -0400
Message-ID: <1304373764.23069.17.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-05-02 at 22:28 +0200, Stef Bon wrote:
> 2011/5/2 Trond Myklebust <Trond.Myklebust@netapp.com>:
> 
> >>
> >> So, what's your opinion?
> >
> > Your proposal requires NFS and CIFS protocol support and I just told you
> > that there is none in NFS...
> 
> Hi,
> 
> yes I've read that. I also have read that there is possibly support
> for in newer versions in NFS.

As I said, there is support for dnotify-like functionality in NFSv4.1,
but no support for inotify, and certainly not for fanotify.

> I imagined that you (not only you but I mean all who are working on
> NFS) are interested to find a good way to do this.

You've proposed a 'solution', but I'm still not seeing what the problem
is.

     1. Why do we need to develop kernel support for dnotify+inotify+...
        in every networked filesystem + fuse?
     2. What are the killer app use cases that we need to support and
        that cannot be supported with existing methods?

Notifications on large distributed filesystems are a scalability
nightmare (particularly so for inotify), so they need careful
justification and need to be limited in scope. Just pulling out a
solution from your magic hat isn't sufficient.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

