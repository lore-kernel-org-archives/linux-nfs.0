Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:45318 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754926Ab2BHPLT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 10:11:19 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<lists@fuchsschwanzdomain.de>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Rv8pq-0000wN-Rk
	for linux-nfs@vger.kernel.org; Wed, 08 Feb 2012 15:49:27 +0100
Received: from sven  by ultimate100.geggus.net (envelope-from
	<lists@fuchsschwanzdomain.de>)
	with local (Exim 4.72)
	id 1Rv8po-0004T2-0H
	for linux-nfs@vger.kernel.org; Wed, 08 Feb 2012 15:49:24 +0100
Date: Wed, 8 Feb 2012 15:49:23 +0100
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: linux-nfs@vger.kernel.org
Subject: NFS4: ID-mapping Problem with Linux Client and NetApp Server
Message-ID: <20120208144923.GA16606@geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm trying to set up a couple of Active-directory integrated Linux machines
using NFS4 volumes on a NetApp Server as storage media.

So far, I'm nearly there, but the final step seems to be missing:

My client (Debian GNU/Linux with nfs-utils 1.2.5) can mount the NetApp
Emulator and Users are managed completely by AD Objects using nslcd.

Now I try to mount the NetApp Emulator vis NFS4 as root:

mount  -t nfs4 -o sec=krb5 dataontap-801.<fqdn>:/vol/v_testhome1/testhome1 /mnt/

This also works, however the NetApp is printing some strange warning:

[nfsd.rpc.request.bad:warning]: Client 10.1.7.174 is sending bad rpc requests with error: RPC version mismatch or authentication error(73)
[nfsd.auth.status.bad:warning]: Client 10.1.7.174 has an authentication error 2

This is probably harmless and caused by the local root which does not have a
valid AD account.

After the mount I can successfully browse the volume as user and my machine
is even able to read/write files to/from the server.

However the files are not owned by the correct users. Server is just sending
me invalid stuff.

Here is the owner string I get from the server looking into the packets using
wireshark:

...
recc_attr: FATTR4_OWNER (36)
    fattr4_owner: root@<fqdn>
        length: 19
        contents: root@<fqdn>
        fill bytes: opaque data
recc_attr: FATTR4_OWNER_GROUP (37)
    fattr4_owner_group: nobody
        length: 6
        contents: nobody
        fill bytes: opaque data

However checking with Windows and SMB these files are not owned by root but
rather by the user which is trying to access the server.

On a Linux machine I would now try to run the server side rpc.idmapd with
verbose options, but unfortunately with NetApp I don't know exactly what to do.

So, any hint what I am missing here?

Client side userid mapping seems to work fine, as I can seen something like
this wehen running rpc.idmapd in verbose mode:

rpc.idmapd: Client 11: (user) name "root@<fqdn>" -> id "0"
rpc.idmapd: Client 11: (group) name "nobody" -> id "65534"

Regards

Sven

-- 
"A strategy for rewarding artists that regulates 'copies' makes as much sense
in the digital age as a strategy for controlling greenhouse gases that
regulates breathing." (Lawrence Lessig)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
