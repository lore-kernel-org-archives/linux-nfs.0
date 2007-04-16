From: Neil Brown <neilb@suse.de>
Subject: Re: mountd randomly crash and panic the server
Date: Mon, 16 Apr 2007 20:47:32 +1000
Message-ID: <17955.21572.383131.837268@notabene.brown>
References: <461CFABE.9050301@barazer.net>
	<46234130.5020502@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdOkb-0006NP-FF
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 03:48:01 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HdOkd-0006OG-CK
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 03:48:03 -0700
In-Reply-To: message from Gabriel Barazer on Monday April 16
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

On Monday April 16, gabriel@oxeva.fr wrote:
> Hello,
> 
> I once again got this crash this night. The call trace always end with 
> the same function (cache_clean), which makes me think that there is 
> maybe a race condition in it (happens randomly, particularly on quite 
> heavy load).
> 
> Apr 16 00:29:45 filer1 kernel:  [<ffffffff8053ae60>]
> cache_flush+0xd/0x23
> Apr 16 00:29:45 filer1 kernel:  [<ffffffff805386e0>] 
> ip_map_parse+0x17c/0x18e
> Apr 16 00:29:45 filer1 kernel:  [<ffffffff8053b4d1>] cache_write+0x90/0xac
> Apr 16 00:29:45 filer1 kernel:  [<ffffffff80213f77>] vfs_write+0xaf/0x151
> Apr 16 00:29:45 filer1 kernel:  [<ffffffff80214907>] sys_write+0x45/0x6e
> Apr 16 00:29:45 filer1 kernel:  [<ffffffff8025311e>] system_call+0x7e/0x83
> Apr 16 00:29:45 filer1 kernel:
> Apr 16 00:29:45 filer1 kernel:
> Apr 16 00:29:45 filer1 kernel: Code: 48 8b 43 08 48 39 82 80 00 00 00 7e 
> 0a 48 ff c0 48 89 82 80
> Apr 16 00:29:45 filer1 kernel: RIP  [<ffffffff8053ad42>] 
> cache_clean+0x11e/0x22f
> 
> Is this related to the kernel cache_clean function in net/sunrpc/cache.c ?

Yes.  It is crashing at:
		for (; ch; cp= & ch->next, ch= *cp) {
			if (current_detail->nextcheck > ch->expiry_time)
                                                        ^^^^^^
				current_detail->nextcheck = ch->expiry_time+1;
			if (ch->expiry_time >= get_seconds()

ch has a garbage value (0001e71926010009), presumable because a
previous cp had been corrupted, most likely by being freed while still
in use.

Bother.

I'll see if I can figure out what is happening.

Thanks for the report.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
