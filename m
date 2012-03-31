Return-Path: linux-nfs-owner@vger.kernel.org
Received: from web100706.mail.kks.yahoo.co.jp ([183.79.100.10]:24807 "HELO
	web100706.mail.kks.yahoo.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750808Ab2CaRU1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Mar 2012 13:20:27 -0400
Message-ID: <68163.71483.qm@web100706.mail.kks.yahoo.co.jp>
Date: Sun, 1 Apr 2012 02:13:42 +0900 (JST)
From: =?iso-2022-jp?B?GyRCTGs/QCEhNGRDSxsoQg==?=
	<supergiantpotato@yahoo.co.jp>
Subject: Re: nfsd hangs for more than 120 seconds
To: linux-nfs@vger.kernel.org
In-Reply-To: <p9nj49-5hf.ln1@homer.bruehl.pontohonk.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



--- On Sun, 2012/4/1, Christoph Bartoschek <ponto@pontohonk.de> wrote:

> Myklebust, Trond wrote:
> 
> > On Sat, 2012-03-31 at 13:55 +0200, Christoph Bartoschek wrote:
> >> Hi,
> >> 
> >> we use Ubuntu 10.04.3 LTS and often get a traceback for NFS indicating
> >> that the daemon hangs for several seconds. At the same time some client
> >> machines cannot access the server and have to wait. After some minutes
> >> everything goes on.
> >> 
> >> What could cause the problem? Is there anything we should change?

> > At a guess, I'd say that your mountd  or rpc.svcgssd is probably
> > busy/hanging, causing the kernel NFS daemon to hang while it waits to
> > authorise a client or user. Typically, you will see the above in the
> > case of a kerberos, NIS or ldap outage.
> > 
> > So are you using NIS or ldap-based netgroups in your /etc/exports, or
> > are your clients perhaps mounting with sys=krb5?

> We are still using NFS3 and NIS. 
> 
> We are also sometimes seeing the following problem that might be related:
> 
> One user suddenly has no access to a directory and its subdirectories on a 
> NFS share. The user always gets "permission denied". The access bits and 
> group memberships did not change.
> 
> At the same time all other users within the same groups can access the 
> directory on the same client machine and on other client machines.
> 
> After about 15 minutes the problem vanishes by itself. The user no longer 
> gets "permission denied" and everything is normal.
> 
> This happens about twice a week for different users. We see no pattern in 
> which user is affected and when this happens.

That sounds a lot like an NIS lookup problem. I've been experiencing hangs (not quite 120 seconds, but over a minute at times, and really annoying) with NFS4 even with an export set this way:

/mnt/export/home *.subdomain.localnet(rw.fsid=0,insecure)
/mnt/export/home *.subdomain.localnet(rw,nohide,insecure)

But its universal, not on a single user. When LDAP was sketchy we used to get a single user or a few users who wouldn't get a complete directory listing of, say, /home/* uid:gid owners, and so that one user would not be able to access anything that didn't come in the listing before it failed until the cache cleared.

But that's been sorted. The only applications that are completely handicapped by the current mystery problem are email clients like Thunderbird and Evolution, and it seems that new requests pass through fine (like a new file browser instance or browsing in Bash works). I've yet to figure that out.
