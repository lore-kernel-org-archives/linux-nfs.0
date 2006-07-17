From: Janos Farkas <chexum+dev@gmail.com>
Subject: Re: nfs problems with 2.6.18-rc1
Date: Mon, 17 Jul 2006 12:08:56 +0200
Message-ID: <priv$efbe06145615$0a94d550eb@200607.gmail.com>
References: <priv$8d118c145575$b19af6759a@200607.shadow.banki.hu>
	<17594.51834.20365.820166@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2Q2l-00061g-71
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 03:09:39 -0700
Received: from nf-out-0910.google.com ([64.233.182.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G2Q2j-0003Rh-W7
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 03:09:39 -0700
Received: by nf-out-0910.google.com with SMTP id m19so446191nfc
	for <nfs@lists.sourceforge.net>; Mon, 17 Jul 2006 03:09:36 -0700 (PDT)
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17594.51834.20365.820166@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 2006-07-17 at 09:23:38, Neil Brown wrote:
> On Thursday July 13, chexum+dev@gmail.com wrote:
> > I recently updated two (old) hosts to 2.6.18-rc1, and started noticing
> > weird things with the nfs mounted /home s.
> So this is both the client and the server that you upgraded?  That
> makes is harder to point the finger of blame :-)

Yeah, smart thing :)  Thank you for the response!  When I have
downgraded the server to 2.6.17, none of those errors happened again.
(And I left the setup that way, because some programs have been
corrupting their config files because of the spurious read errors --
most notably zsh and firefox.)

> I wonder if that is pointing the finger at
> 
> http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=8c7b389e532e964f07057dac8a56c43465544759
> 
> as that is a recent change that returns 'EACCES'... but I cannot see
> that being relevant in this case as it only affects directories.

As far as I can see, that patch is from May 21st, and went in 17-rc5,
thus obviously 2.6.17 is newer than that...  But a bunch of nfs changes
happened in 18-rc1.

> The standard answer for tracing nfs problems if 'tcpdump'.
> e.g. 
>   tcpdump -s 0 -w /tmp/trace host $CLIENT and host $SERVER and port 2049
> 
> that should show whether the error is coming from the server, or if
> the client is generating it all by itself.

Well, I tried that, but I couldn't see errors flying on the wire.  That
would point to flaws in the 18-rc1 client (but only surfacing with an
rc1 server?), or in my eyes :)

> Also turn on tracing. Something like:
> on server
>    echo 32767 > /proc/sys/sunrpc/nfsd_debug
> on client
>    echo 32767 > /proc/sys/sunrpc/nfs_debug
> 
> You can be a bit more selective by only enabling individual flags.
> For the server, these are in include/linux/nfsd/debug.h
> You probably want FH, EXPORT AUTH PROC FILEOP
> 
> For the client, they are near the end of include/linux/nfs_fs.h
> Not sure which to choose... maybe just all of them.

Thanks, that's probably what I've been looking for.  I'll try to debug
this with a 2.6.18-rc2(client):2.6.17(server) and 2.6.18-rc2(both) setup
later this day, but those machines are currently in the process of
reorganizing their RAID config :)

-- 
Janos
romfs is at http://romfs.sourceforge.net/


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
