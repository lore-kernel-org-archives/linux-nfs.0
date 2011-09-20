Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40729 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168Ab1ITNuv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 09:50:51 -0400
Date: Tue, 20 Sep 2011 09:50:50 -0400
To: Tim <supertimothy@web.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Writing / Locking problem with NFSv4
Message-ID: <20110920135050.GA12422@fieldses.org>
References: <001101cc745e$356aeed0$a040cc70$@web.de>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <001101cc745e$356aeed0$a040cc70$@web.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 16, 2011 at 12:48:45PM +0200, Tim wrote:
> Im  facing a rather strange problem. 
> 
> From one client I can mount and access my NFSServer without any problems.
> Writing and locking works with a non root user accout. 
> From another client (in another subnet), with root everything works fine. If
> I use another user, locking doesnt work and also when I create a file with
> vim, the *.swp file is not deleted afterwards. But reading works without
> problems. 
> Strange thing is user mapping seems to work correct  at least what ls -la
> and the logfiles for idmapd shows. 

Which client and server?  (Linux on both?  Which versions?)  Are you
using kerberos?  If not, are your uid's the same between client and
server?  What does your export file look like?

--b.
