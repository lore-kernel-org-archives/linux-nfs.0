Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:61028 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757896Ab2IYRuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Sep 2012 13:50:35 -0400
Date: Tue, 25 Sep 2012 13:50:25 -0400
From: Jim Rees <rees@umich.edu>
To: Orion Poplawski <orion@cora.nwra.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Any way to allow setuid daemon to access krb5 automounted nfs
 directories?
Message-ID: <20120925175025.GA8020@umich.edu>
References: <5061DF69.8030606@cora.nwra.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5061DF69.8030606@cora.nwra.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Orion Poplawski wrote:

  Is there any way to allow setuid daemon to access krb5 automounted
  nfs directories?  Specifically I'm looking to run spamassassin's
  spamd on a remote server and access user's home directories via krb5
  nfs4.  spamd changes user to the user receiving the email being
  processes and needs to modify files in the user's home directory.
  Is there any reasonably secure way to give this daemon the ability
  to do this?  Any way to tell rpc.gssd to use a specific credential
  cache for this type of access rather than the default for that
  effective uid?

You don't want to give spamd the user's credentials. You want to acl the
user's files so that spamd can do what it wants. Spamd will need its own
krb5 principal.

But I hope you're not planning to deliver mail over nfs. I think that would
be a mistake.
