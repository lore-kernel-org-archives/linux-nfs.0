Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dot.freshdot.net ([213.154.236.176]:39870 "EHLO
	dot.freshdot.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932816AbbJMR7j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 13:59:39 -0400
Date: Tue, 13 Oct 2015 19:59:37 +0200
From: Sander Smeenk <ssmeenk@freshdot.net>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: CAP(abilities) and NFS mounted storage
Message-ID: <20151013175937.GG10632@dot.dmz.freshdot.net>
References: <20151013122128.GD10632@dot.dmz.freshdot.net>
 <CAHQdGtRUrWuahu7iQbQQLUeB_ZPFoqFLTXFhHa0pCuKGp9ycWA@mail.gmail.com>
 <20151013143445.GE10632@dot.dmz.freshdot.net>
 <CAN-5tyFNor0HmY5xMM7EVfGtec8U2iUVk8942xzC6sAP4Yn4sA@mail.gmail.com>
 <CAHQdGtTF5OiCoQ++Tqk=PpwWYXaL9rG38DaeGUqcezfEYOudSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTF5OiCoQ++Tqk=PpwWYXaL9rG38DaeGUqcezfEYOudSg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Trond Myklebust (trond.myklebust@primarydata.com):
> >>> > I've experimented with different capabilties, but CAP_DAC_OVERRIDE is
> >>> > not enough. I'd very much like to hear if it is possible for this to
> >>> > work on NFS like it does on local storage.
> >>> This will not work on NFS. The server, which enforces permissions, has
> >>> no way to know what capabilities your process has on the client.
> >> Thanks. I feared this answer. But i understand that the NFS-server cant
> >> know if the process on the NFS-client has CAP_DAC_READ_SEARCH
> >> capabilities set.
> >> Would setfsuid() help anything in this case? Or is it just a big no-go?
> 
> setfsuid() would allow you to set a user up with root privileges on
> the fs. That's better than giving overall root privileges, but is
> still a risk, since a user could use it to overwrite /etc/passwd etc.

I'm not going to run anything i'm trying in a production environment yet. ;)

But, should setfsuid() work with NFS-mounted filesystems too?
'Cause i tried, but it didn't seem to change much (w/ caps set).
Might be i need more capabilities for that to work. Hmm.


> > Are you looking for something like labeled NFS that supports
> > capabilities? I think Redhat7 has SElinux labeled NFS support.
> 
> The labeled NFS implementation is client enforced and confers no extra
> privileges on the server. Plus (please correct me if I'm wrong), I
> believe NetApp has yet to announce support for labeled NFS in OnTAP.

Yes. This is not really an option. ;)


Regards,
-Sndr.
-- 
| Spend some time trying hard not to think about giraffes.
| 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
