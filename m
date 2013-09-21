Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm43-vm5.bullet.mail.bf1.yahoo.com ([216.109.114.236]:47766
	"EHLO nm43-vm5.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752119Ab3IUOg0 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 21 Sep 2013 10:36:26 -0400
References: <1379582806.44080.YahooMailNeo@web140003.mail.bf1.yahoo.com> <20130919131429.GA20422@fieldses.org> <1379597501.95818.YahooMailNeo@web140002.mail.bf1.yahoo.com> <20130919134028.GB20422@fieldses.org> <1379599410.72261.YahooMailNeo@web140001.mail.bf1.yahoo.com> <20130919140846.GC20422@fieldses.org> <1379600464.91434.YahooMailNeo@web140005.mail.bf1.yahoo.com> <20130919142535.GD20422@fieldses.org> <1379601992.25969.YahooMailNeo@web140005.mail.bf1.yahoo.com> <20130919151551.GE20422@fieldses.org> <1379760686.37618.YahooMailNeo@web140003.mail.bf1.yahoo.com>
Message-ID: <1379774184.36485.YahooMailNeo@web140006.mail.bf1.yahoo.com>
Date: Sat, 21 Sep 2013 07:36:24 -0700 (PDT)
From: Jody Gugelhupf <knueffle@yahoo.com>
Reply-To: Jody Gugelhupf <knueffle@yahoo.com>
Subject: Re: help with nfs export/mount
To: Jody Gugelhupf <knueffle@yahoo.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1379760686.37618.YahooMailNeo@web140003.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

but now my syslog and dmesg on nfs serverside is full of these msg'es:

Sep 21 16:34:13 fatzo kernel: [8295937.032636] RPC:       Want update, refage=120, age=116
Sep 21 16:34:21 fatzo kernel: [8295945.056091] RPC:       Want update, refage=120, age=0
Sep 21 16:34:26 fatzo kernel: [8295950.056027] RPC:       Want update, refage=120, age=5
Sep 21 16:34:31 fatzo kernel: [8295955.056024] RPC:       Want update, refage=120, age=10
Sep 21 16:34:36 fatzo kernel: [8295960.056024] RPC:       Want update, refage=120, age=15
Sep 21 16:34:41 fatzo kernel: [8295965.056095] RPC:       Want update, refage=120, age=20
Sep 21 16:34:46 fatzo kernel: [8295970.056030] RPC:       Want update, refage=120, age=25
Sep 21 16:34:51 fatzo kernel: [8295975.056046] RPC:       Want update, refage=120, age=30
Sep 21 16:35:05 fatzo kernel: [8295989.155466] RPC:       Want update, refage=120, age=44
Sep 21 16:35:10 fatzo kernel: [8295994.152029] RPC:       Want update, refage=120, age=49
Sep 21 16:35:15 fatzo kernel: [8295999.152050] RPC:       Want update, refage=120, age=54
Sep 21 16:35:26 fatzo kernel: [8296010.195221] RPC:       Want update, refage=120, age=65
Sep 21 16:35:31 fatzo kernel: [8296015.192028] RPC:       Want update, refage=120, age=70
Sep 21 16:35:47 fatzo kernel: [8296031.235390] RPC:       Want update, refage=120, age=86
Sep 21 16:35:52 fatzo kernel: [8296036.232029] RPC:       Want update, refage=120, age=91
Sep 21 16:35:57 fatzo kernel: [8296041.232100] RPC:       Want update, refage=120, age=96
Sep 21 16:36:08 fatzo kernel: [8296052.275643] RPC:       Want update, refage=120, age=107
Sep 21 16:36:13 fatzo kernel: [8296057.272027] RPC:       Want update, refage=120, age=112
Sep 21 16:36:29 fatzo kernel: [8296073.315985] RPC:       Want update, refage=120, age=0
Sep 21 16:36:34 fatzo kernel: [8296078.312026] RPC:       Want update, refage=120, age=5
Sep 21 16:36:39 fatzo kernel: [8296083.312096] RPC:       Want update, refage=120, age=10
Sep 21 16:36:50 fatzo kernel: [8296094.356721] RPC:       Want update, refage=120, age=21
Sep 21 16:36:55 fatzo kernel: [8296099.356097] RPC:       Want update, refage=120, age=26
Sep 21 16:37:03 fatzo kernel: [8296107.389078] RPC:       Want update, refage=1800, age=903
Sep 21 16:37:11 fatzo kernel: [8296115.367365] RPC:       Want update, refage=120, age=42
Sep 21 16:37:16 fatzo kernel: [8296120.364090] RPC:       Want update, refage=120, age=47
Sep 21 16:37:21 fatzo kernel: [8296125.364043] RPC:       Want update, refage=120, age=52
Sep 21 16:37:33 fatzo kernel: [8296136.418063] RPC:       Want update, refage=120, age=63
Sep 21 16:37:38 fatzo kernel: [8296141.416131] RPC:       Want update, refage=120, age=68
Sep 21 16:37:54 fatzo kernel: [8296157.441174] RPC:       Want update, refage=120, age=85
Sep 21 16:37:59 fatzo kernel: [8296162.440067] RPC:       Want update, refage=120, age=90
Sep 21 16:38:04 fatzo kernel: [8296167.440097] RPC:       Want update, refage=120, age=95
Sep 21 16:38:15 fatzo kernel: [8296178.501474] RPC:       Want update, refage=120, age=106
Sep 21 16:38:19 fatzo kernel: [8296182.467950] RPC:       Want update, refage=1800, age=907
Sep 21 16:38:20 fatzo kernel: [8296183.500042] RPC:       Want update, refage=120, age=111
Sep 21 16:38:35 fatzo kernel: [8296198.952120] RPC:       Want update, refage=120, age=0
Sep 21 16:38:40 fatzo kernel: [8296203.952047] RPC:       Want update, refage=120, age=5
Sep 21 16:38:45 fatzo kernel: [8296208.952030] RPC:       Want update, refage=120, age=10
Sep 21 16:38:50 fatzo kernel: [8296213.952032] RPC:       Want update, refage=120, age=15
Sep 21 16:38:55 fatzo kernel: [8296218.952025] RPC:       Want update, refage=120, age=20
Sep 21 16:39:00 fatzo kernel: [8296223.953579] RPC:       Want update, refage=120, age=20
tired to find something about this but not much returned, 



----- Original Message -----
From: Jody Gugelhupf <knueffle@yahoo.com>
To: J. Bruce Fields <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sent: Saturday, September 21, 2013 12:51:26 PM
Subject: Re: help with nfs export/mount

thanks a lot!!!

I tried the commands you suggested below for further debug and this one:
cat /proc/net/rpc/nfsd.export/content

showed me a folder that was first "mount --bind" into one of the exported folders and later it was moved from the original storage location but the "mount --bind" wasn't removed, that caused some sort of error and thus the nfs mounts were not working, once i corrected the original location of that "mount --bind" it all worked :)


----- Original Message -----
From: J. Bruce Fields <bfields@fieldses.org>
To: Jody Gugelhupf <knueffle@yahoo.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sent: Thursday, September 19, 2013 5:15:51 PM
Subject: Re: help with nfs export/mount

On Thu, Sep 19, 2013 at 07:46:32AM -0700, Jody Gugelhupf wrote:
> ah ok, i have dropped the "fsid=0" as you had suggested but had still mounted with "sudo mount 192.168.2.3:/ /home/jarvis/Videos/xbmc"
> though when doing tab completition on cli it does show 
> ls /home/jarvis/Videos/xbmc/
> ls /home/jarvis/Videos/xbmc/home
> 
> ls /home/jarvis/Videos/xbmc/home/user
> 
> ls /home/jarvis/Videos/xbmc/home/user/media
> 
> ls /home/jarvis/Videos/xbmc/home/user/media/Series
> 
> and then hangs indeed

That does sound like a kernel or mountd bug.  Possibly it's confused by
the bind mounts.  Could you post the contents of /proc/self/mounts on
the server?

Also, reproduce the hang as above on the client, then as root on the
server, run:

    rpcdebug -m rpc -s cache
    cat /proc/net/auth.unix.ip/content
    cat /proc/net/rpc/nfsd.fh/content
    cat /proc/net/rpc/nfsd.export/content

and post the output.

Finally if you're up to building the latest nfs-utils and kernel from
source it would be interesting to know whether the bug persists
upstream.

--b.

> 
> 
> 
> 
> ----- Original Message -----
> From: J. Bruce Fields <bfields@fieldses.org>
> To: Jody Gugelhupf <knueffle@yahoo.com>
> Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
> Sent: Thursday, September 19, 2013 4:25:35 PM
> Subject: Re: help with nfs export/mount
> 
> On Thu, Sep 19, 2013 at 07:21:04AM -0700, Jody Gugelhupf wrote:
> > on client side (in order):
> > 
> > sudo mount 192.168.2.3:/ /home/jarvis/Videos/xbmc
> 
> As I said, if you've dropped the "fsid=0" (which you should) then you
> should be mounting the real server-side path, not /.
> 
> > no error msg, then trying to access the directory:
> > ls /home/jarvis/Videos/xbmc/home/user/media/Series
> > the console does not react,
> 
> So the mount succeeds, but the "ls" hangs?
> 
> --b.
> 
> > i open a new console and see again 
> > Sep 19 14:15:56 darkstar kernel: [61095.429346] nfs: server 192.168.2.3 OK
> > Sep 19 14:17:01 darkstar kernel: [61280.169706] nfs: server 192.168.2.3 not responding, still trying
> > 
> > 
> > but i also noticed this (didn't see it before)
> > Sep 19 16:12:53 darkstar rpc.idmapd[576]: nss_getpwnam: name 'user' not found in domain 'localdomain'
> > 
> > 
> > 
> > ----- Original Message -----
> > From: J. Bruce Fields <bfields@fieldses.org>
> > To: Jody Gugelhupf <knueffle@yahoo.com>
> > Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
> > Sent: Thursday, September 19, 2013 4:08:46 PM
> > Subject: Re: help with nfs export/mount
> > 
> > On Thu, Sep 19, 2013 at 07:03:30AM -0700, Jody Gugelhupf wrote:
> > > on server side I see in dmesg this:
> > > [8040437.603605] nfsd: last server has exited, flushing export cache
> > > [8040439.496016] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> > > [8040439.496035] NFSD: starting 90-second grace period
> > > 
> > > on client side i only see:
> > > Sep 19 13:27:56 darkstar kernel: [61095.429346] nfs: server 192.168.2.3 OK
> > > Sep 19 13:31:01 darkstar kernel: [61280.169706] nfs: server 192.168.2.3 not responding, still trying
> > >  is there a way to further debug?
> > 
> > Exactly what commands did you type, and what things happened, in what
> > order?
> > 
> > --b.
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

