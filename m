Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51922 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753941Ab0LFSE3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Dec 2010 13:04:29 -0500
Date: Mon, 6 Dec 2010 13:04:27 -0500
To: rauch.holger@googlemail.com
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4: rpc.svcgssd claims that no machine credentials exist
Message-ID: <20101206180427.GA32657@fieldses.org>
References: <20101202020509.GA6526@gmail.com>
 <1291257241.6609.104.camel@heimdal.trondhjem.org>
 <20101204233627.GD5862@gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101204233627.GD5862@gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Dec 05, 2010 at 12:36:28AM +0100, rauch.holger@googlemail.com wrote:
> Hi Trond,
> 
> thanks for your reply. Please see my answer(s) below.
> 
> On Wed, 01 Dec 2010, Trond Myklebust wrote:
> 
> > [...] 
> > ::1	my.host.name
> > 
> > would completely screw up MIT kerberos's (and hence rpc.svcgssd's)
> > ability to figure out the correct fdqn for my server.
> 
> Ok, but I have IPv6 disabled and thus also no such line in my /etc/hosts
> file since I removed it manually.

It could still be some problem with /etc/hosts; googling "/etc/hosts
kerberos" may get you more.  And see also
http://www.citi.umich.edu/projects/nfsv4/linux/faq/.

> > [...]
> > Unfortunately, NetworkManager loves to add 'my.host.name' to any
> > existing '::1' line. The only solution I've found so far is to disable
> > NetworkManager on my server.
> 
> I use Debian which doesn't use NetworkManager.
> 
> > 
> > The other interesting rpcsec bug I found recently had to do with
> > selinux: apparently MIT kerberos also likes to create a
> > [...]
> 
> selinux is disabled as well.
> 
> > [...]
> 
> FYI, I also ran strace on the mentioned invocation of rpc.svcgssd but I
> couldn't figure out the principal name rpc.svcgssd is really looking for.
> How can I figure this out? Do I need some to enable debug logging in my
> /etc/krb5.conf file?

Adding -vvv to the rpc.svcgssd line may give you that information, I
can't remember.

--b.
