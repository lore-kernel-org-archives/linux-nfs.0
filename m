Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:35335 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab1EBO4k convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 10:56:40 -0400
Received: by iwn34 with SMTP id 34so4700637iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 02 May 2011 07:56:39 -0700 (PDT)
In-Reply-To: <1304347155.7830.7.camel@lade.trondhjem.org>
References: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
	<20110502140750.GA10885@fieldses.org>
	<BANLkTinTu8XVmxkUUhJby8=DNY4sZF5VAQ@mail.gmail.com>
	<1304347155.7830.7.camel@lade.trondhjem.org>
Date: Mon, 2 May 2011 16:56:39 +0200
Message-ID: <BANLkTikZnnt0cmpP4iT4Q4EJTxZnSC_SYQ@mail.gmail.com>
Subject: Re: How does NFS handle notify?
From: Stef Bon <stefbon@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sorry,

Gamin is in the first place completly useless in my case. Futher I've
tried to contact the developer of gamin, but no response at all, from
different addresses.

And also with other fs's like cifs (and I think nfs as well), what I
try to achieve is that the fs self is responsible for the handling of
the inotify request.

How to do this? First possible via VFS, clients will set a watch on
(mounted) fs directly, VFS handles this call and forwards it to the
mounted fs. I write here forward, I mean sends a signal to the mounted
fs about a notify watch being set on a inode. After that (and being
successfull) the VFS opens a fd the mounted fs can send events to when
something happens on the inode (what is significant).

Next via a daemon like Gamin. Yes, possible, but is this smart? Isn't
it just possible through the VFS like above described.

Stef


2011/5/2 Trond Myklebust <Trond.Myklebust@netapp.com>:
> On Mon, 2011-05-02 at 16:29 +0200, Stef Bon wrote:
>> Ok,
>>
>> so as I understand NFS does not support it yet. I thought it does.
>>
>> Are you interested when I set up a project to work on the VFS to make
>> it possible to
>> make the mounted fs notified (by the VFS) that a  notify watch is set
>> (or removed)?
>> I guess the developers of cifs are interested too, and me, as
>> developer of a FUSE fs.
>
> http://people.gnome.org/~veillard/gamin/
>
> Cheers
>  Trond
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
>
