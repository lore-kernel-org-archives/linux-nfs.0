Return-Path: linux-nfs-owner@vger.kernel.org
Received: from terminus.zytor.com ([198.137.202.10]:53039 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758239Ab2HJSoN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 14:44:13 -0400
Message-ID: <50255618.9080708@zytor.com>
Date: Fri, 10 Aug 2012 11:42:32 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
CC: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Trond.Myklebust@netapp.com, davem@davemloft.net,
        linux-nfs@vger.kernel.org, eric.dumazet@gmail.com, xemul@parallels.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, viro@zeniv.linux.org.uk,
        tim.c.chen@linux.intel.com, devel@openvz.org
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified root
References: <20120810125701.7115.71612.stgit@localhost.localdomain> <50254FA6.3060806@zytor.com> <20120810192628.79a34d28@pyramind.ukuu.org.uk> <5025537D.9060300@zytor.com> <20120810194028.792f29f1@pyramind.ukuu.org.uk>
In-Reply-To: <20120810194028.792f29f1@pyramind.ukuu.org.uk>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2012 11:40 AM, Alan Cox wrote:
> 
> Agreed on open() for sockets.. the lack of open is a Berklix derived
> pecularity of the interface. It would equally be useful to be able to
> open "/dev/socket/ipv4/1.2.3.4/1135" and the like for scripts and stuff
> 
> That needs VFS changes however so you can pass the remainder of a path to
> a device node. It also lets you do a lot of other sane stuff like
> 
> 	open /dev/ttyS0/9600/8n1
> 

Well, supporting device node subpaths would be nice, but I don't think
that that is a requirement either for being able to open() a socket (as
a Linux extension) nor for supporting something like your above
/dev/socket/... since that could be done with a filesystem rather than
just a device node.

	-hpa
