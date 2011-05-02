Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44205 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756223Ab1EBOHv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2011 10:07:51 -0400
Date: Mon, 2 May 2011 10:07:50 -0400
To: Stef Bon <stefbon@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: How does NFS handle notify?
Message-ID: <20110502140750.GA10885@fieldses.org>
References: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, May 01, 2011 at 11:33:32AM +0200, Stef Bon wrote:
> Mentioned there - and I agree - that when developing support for
> notify on mounted filesystems you need to have one base (in VFS), and
> a part which is handled by the (mounted) fs self.
> 
> So here my question, how does NFS handle notify??

No.  It might be possible with new features in the 4.1 version of the
protocol (http://tools.ietf.org/html//rfc5661#section-10.9).

--b.
