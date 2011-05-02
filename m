Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23927 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759762Ab1EBOjQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 10:39:16 -0400
Subject: Re: How does NFS handle notify?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stef Bon <stefbon@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
In-Reply-To: <BANLkTinTu8XVmxkUUhJby8=DNY4sZF5VAQ@mail.gmail.com>
References: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
	 <20110502140750.GA10885@fieldses.org>
	 <BANLkTinTu8XVmxkUUhJby8=DNY4sZF5VAQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 02 May 2011 10:39:15 -0400
Message-ID: <1304347155.7830.7.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-05-02 at 16:29 +0200, Stef Bon wrote:
> Ok,
> 
> so as I understand NFS does not support it yet. I thought it does.
> 
> Are you interested when I set up a project to work on the VFS to make
> it possible to
> make the mounted fs notified (by the VFS) that a  notify watch is set
> (or removed)?
> I guess the developers of cifs are interested too, and me, as
> developer of a FUSE fs.

http://people.gnome.org/~veillard/gamin/

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

