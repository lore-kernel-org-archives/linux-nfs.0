From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Fri, 27 Jun 2008 13:44:03 -0400
Message-ID: <20080627174403.GD18933@fieldses.org>
References: <62137472-FF31-40A2-904D-A9CC2C76B032@oracle.com> <OF3C28594A.91157CD9-ON65257475.0029EEE9-65257475.0031D7A5@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41366 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755520AbYF0Rod (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jun 2008 13:44:33 -0400
In-Reply-To: <OF3C28594A.91157CD9-ON65257475.0029EEE9-65257475.0031D7A5@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 27, 2008 at 02:34:24PM +0530, Krishna Kumar2 wrote:
> But if the file is being shared only with one client (and that too
> locally),
> isn't 25% too high?
> 
> Will I get better results on NFSv4, and should I try delegation (that
> sounds
> automatic and not something that the user has to start)?

No, delegation couldn't possibly help in this case--more caching can't
help if you're only reading the file once.

--b.
