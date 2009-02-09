From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC PATCH 0/1] nfsd: Improve NFS server performance
Date: Mon, 9 Feb 2009 16:04:27 -0500
Message-ID: <20090209210427.GJ13636@fieldses.org>
References: <20081230104245.9409.30030.sendpatchset@localhost.localdomain> <20090204231958.GB20917@fieldses.org> <OF46E14C36.93250375-ON65257554.0050CEC8-65257554.005328DC@in.ibm.com> <20090205202401.GH9200@fieldses.org> <OFC7146FC3.ABEF6E81-ON65257556.001EB1D9-65257556.0032B679@in.ibm.com> <20090209190648.GA13636@fieldses.org> <01164826-9C05-41E0-A763-825A9C6E8CFF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:43622 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbZBIVEX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 16:04:23 -0500
In-Reply-To: <01164826-9C05-41E0-A763-825A9C6E8CFF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 09, 2009 at 03:56:16PM -0500, Chuck Lever wrote:
> On Feb 9, 2009, at 2:06 PM, J. Bruce Fields wrote:
>>
>> No.  People have talked about doing that, but it hasn't happened.
>
> It should be noted that mountd's UMNT and UMNT_ALL requests (used by  
> NFSv2/v3) are advisory, and that our NFSv4 client doesn't contact the  
> server at unmount time.

We're not talking about a client unmounting a server, but about a server
unmounting an exported filesystem.

--b.
