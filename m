From: Timo Sirainen <tss@iki.fi>
Subject: Re: [NFS] Cache flushing
Date: Sun, 18 Nov 2007 02:26:14 +0200
Message-ID: <6513EED9-82AA-4613-A207-686CFFB95430@iki.fi>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina>
	<1195343531.7084.11.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: multipart/mixed; boundary="===============2095146144=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItXyl-0004Sc-I3
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 16:25:39 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ItXyp-0002XO-7Y
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 16:25:44 -0800
In-Reply-To: <1195343531.7084.11.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============2095146144==
Content-Type: multipart/signed; protocol="application/pgp-signature";
	micalg=pgp-sha1; boundary="Apple-Mail-24-142526131"
Content-Transfer-Encoding: 7bit

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-24-142526131
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed

On 18.11.2007, at 1.52, Trond Myklebust wrote:

>> close()+open() would have been difficult to handle because open() can
>> fail, but looks like opening another file descriptor and closing it
>> works just as well. Also looks like it works for flushing  
>> directories'
>> attribute cache (which doesn't seem to work with FreeBSD though).
>>
>> There's one potential problem with closing a file descriptor  
>> though. It
>> loses all fcntl locks for that file from all fds. I'm not sure if  
>> this a
>> problem for me though.
>
> Right. I understood that you were not using fcntl() locks. Those  
> will in
> any case ensure cache revalidation, so you wouldn't have to use  
> anything
> else.

That assumes that locks are used in a typical "read lock" and "write  
lock" way. Dovecot currently does, but not necessarily in future. For  
example UW-IMAP's mbx format requires grabbing a shared lock when the  
mailbox is opened and keeping it until the mailbox is closed. The  
shared lock prevents messages from being deleted from the file, but  
it doesn't prevent message flag updates or appending new messages to  
the file. To see if there are new messages would require flushing  
attribute cache to get the file size updated, but close+open wouldn't  
work because it would drop the shared lock and drop the guarantee  
that no messages get deleted while the mailbox is open.

> Again, you can use the close-to-open trick of simply reopening the  
> file
> whenever you need to revalidate the data cache.
>
> The problem, however, is that on the most common Linux filesystems
> (ext2/ext3, reiserfs,...) the time resolution on the mtime is 1  
> second.
> If your NFS server is running one of those filesystems, then the data
> cache revalidation may fail to detect a write that happens within 1
> second of the previous write.

Most people are using NetApps, and they also seem to have 1 second  
resolution (at least the one I just tested had). So this isn't a  
solution. "Let's hope that there are no writes less than 1 second  
apart" isn't really a solution either. People like their mailboxes  
uncorrupted.

--Apple-Mail-24-142526131
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: This is a digitally signed message part
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (Darwin)

iD8DBQFHP4amyUhSUUBViskRApDiAJ9MM1m9GdgkuGdD8f3LiH4oeKCukACdEgkp
k1D9JKI06J1oIqGXLX4qnIo=
=HHdz
-----END PGP SIGNATURE-----

--Apple-Mail-24-142526131--


--===============2095146144==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============2095146144==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============2095146144==--


