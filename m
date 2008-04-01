From: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Subject: NFS3+KRB5 question
Date: Tue, 1 Apr 2008 10:51:09 +0200
Message-ID: <35b652ed9c3ac37ca9dc102b1bb65a83@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:34616
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755328AbYDAI6p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Apr 2008 04:58:45 -0400
Received: from [127.0.0.1] (helo=mail.maru.homelinux.org ident=IpuIqVwe)
	by gibson.comsick.at with esmtp (Exim 4.69)
	(envelope-from <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>)
	id 1JgcCz-0006GW-Kp
	for linux-nfs@vger.kernel.org; Tue, 01 Apr 2008 10:51:09 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello list.

I am facing a strange behaviour here with a test NFS3+KRB5 setup.
I am currently testing NFS4+KRB5 and everything seems to work ok.

#NFS4 export snippet
/srv/nfs4  *(sec=krb5,rw,async,fsid=0,insecure,crossmnt,no_subtree_check)
/srv/nfs4/media  *(sec=krb5,rw,async,insecure,crossmnt,no_subtree_check)

Both the server and client linux machine are running nfs-utils 1.1.2.

I can mount these exports with.

    mount -t nfs4 -osec=krb5 servername:/ /mnt

Now I tried the same with an NFS3 export.

#NFS3 export snippet
/var/media
192.168.0.0/24(sec=krb5:krb5i:krb5p:sys,rw,async,insecure,no_subtree_check)

If I try to mount this export form my client it works

   mount -osec=krb5 servername:/var/media /mnt

I can see that rpc.gssd on the client is doing its work fetching a ticket
etc....
But as you can see i still have sec=...:sys in this export line.

If I remove sys from sec I can NO LONGER mount this share from my linux
client. 
Although I see a authenticated line in the server logs several times, the
mount does not succeed.
Furthermore the rpc.gssd daemon on the client does not do anything in this
case (I let it run in foreground to check it).
As soon as I add sec=...:sys to the export, mounting via -osec=krb5 works
again and I can also see rpc.gssd doing its work.

For testing purposes I tried to mount the same export from a mac client
(leopard) and this worked with and without the sec=sys.

So my question. Do you still need to have sec=sys in your exports even if
you just want to mount them via kerberos or is this a bug?
The server is running kernel version 2.6.24.2 and the linux client
2.6.25-rc2. I also tried to mount export from the server itself but it
failed the same way.

Kind regards,
Michael


