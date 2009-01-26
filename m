Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:35181 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723AbZAZTOv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Jan 2009 14:14:51 -0500
Subject: Re: nfs4 with sec=krb5, mount times out
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Kevin Coffman <kwc@citi.umich.edu>
Cc: Julius <commercials@gmx.net>, NFS list <linux-nfs@vger.kernel.org>
In-Reply-To: <4d569c330901261059x70913131j4dc1dec4809bc1f4@mail.gmail.com>
References: <1232994250.3310.221.camel@wf>
	 <4d569c330901261059x70913131j4dc1dec4809bc1f4@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 26 Jan 2009 14:14:44 -0500
Message-Id: <1232997284.15556.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2009-01-26 at 13:59 -0500, Kevin Coffman wrote:
> On Mon, Jan 26, 2009 at 1:24 PM, Julius <commercials@gmx.net> wrote:
> > Hi,
> >
> >
> > i can mount my nfsv4 share without kerberos security without
> > problems.../etc/fstab:
> >
> > night_crawler.localdomain.de:/music /home/metalfan/nfs4-mount   nfs4    user
> > 0       0
> >
> >
> > but adding "sec=krb5" to the options list results in:
> >
> >
> > mount -v nfs4-mount/
> > mount.nfs4: timeout set for Mon Jan 26 15:44:05 2009
> > mount.nfs4: text-based options:
> > 'sec=krb5,clientaddr=141.x.x.x,addr=141.x.x.x
> > mount.nfs4: mount(2): Connection timed out
> >
> >
> > I read somewhere on the mailing list that only des-cbc-crc is supported
> > for nfs4, its the only keytype for my user metalfan.
> > "kinit metalfan" was run before attempting to mount.
> > i can use gssapi to connect to night_crawlers sshd with my local user,
> > which also does the nfs4 mount.
> >
> > krb5-kdc.log and krb5-default.log do not show any connections.
> > Where do you start troubleshooting?
> 
> First step would be to verify that rpc.gssd is running on your client
> machine, and rpc.svcgssd is running on your server machine.
> You need to generate a keytab for your server (with only a des-cbc-crc
> key).  (nfs/<f.q.h.n>@<REALM>)
> You likely need to generate a keytab for your client as well.
> 
> If all those are done, send output of rpc.gssd and rpc.svcgssd
> (running with option -vvv).
> 
> I would point you at our FAQ page, but the web server is sadly still
> down at the moment.
> 

There is always the wiki...

http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos

Cheers
  Trond

