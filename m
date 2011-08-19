Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45943 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755491Ab1HST3l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 15:29:41 -0400
Date: Fri, 19 Aug 2011 15:29:40 -0400
To: paul.szabo@sydney.edu.au
Cc: linux-nfs@vger.kernel.org
Subject: Re: Please support NSF squashing multiple groups
Message-ID: <20110819192940.GB1641@fieldses.org>
References: <201108190032.p7J0W3ZX030679@bari.maths.usyd.edu.au>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201108190032.p7J0W3ZX030679@bari.maths.usyd.edu.au>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 19, 2011 at 10:32:03AM +1000, paul.szabo@sydney.edu.au wrote:
> Dear Linux-NFS people,
> 
> NFS has always had the root_squash option, to protect against a remote
> and possibly evil root. NFS should also protect all privileged, or at
> least all root-equivalent, UIDs and GIDs. Many UNIX distributions have
> root-equivalent GIDs, groups whose members could easily become root,
> some listed in http://bugs.debian.org/299007#219 .

Hm.  It depends on what you're using the exports for, I suppose.  If the
server exports something it doesn't itself use for anything important
then the server should be safe against clients.  The clients though may
be able to attack each other if say /usr/bin is mounted over NFS and
is writeable by some non-root group.  OK, I guess that's what you're
saying.

> Currently, NFS has no ways to protect privileged UIDs and GIDs other
> than root himself. Such options should be implemented, to make NFS
> safer and more useful. As I understand it, the hold-up is not within
> NFS code, but with kernel interfaces not supporting lists of squashed
> entities. I am asking you to devise and implement such interfaces.

That's not a small project, so we'd need a volunteer.  As Neil says
kerberos might also help.

--b.
