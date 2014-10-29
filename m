Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46720 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932985AbaJ2Oro (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2014 10:47:44 -0400
Date: Wed, 29 Oct 2014 10:47:41 -0400
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: lua extention for wireshak to trace nfs server latencies
Message-ID: <20141029144741.GA1133@fieldses.org>
References: <74264531.872138.1414263726250.JavaMail.zimbra@desy.de>
 <340559201.872226.1414264413792.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <340559201.872226.1414264413792.JavaMail.zimbra@desy.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 25, 2014 at 09:13:33PM +0200, Mkrtchyan, Tigran wrote:
> recently I was debugging some NFS related issues and
> needed a tool to trace situations when NFS server is slow.
> 
> I created a lua extension for tshark which allows to get
> such information, but still has the full power of tshark.
...
> May be some one need's it as well:  https://github.com/kofemann/wireshark_lua
> 
> 
> P.S.: is it the right place for such posts or there yet another mailing list or wiki?

I guess I'd be inclined to cross-post such things to nfsv4@ietf.org.  I
don't know how else to reach implementors across OS's.

You're welcome to add things to wiki.linux-nfs.org too.

--b.
