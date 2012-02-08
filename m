Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26682 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753859Ab2BHPdt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 10:33:49 -0500
Message-ID: <4F3295CC.7020503@netapp.com>
Date: Wed, 08 Feb 2012 10:33:32 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Sven Geggus <lists@fuchsschwanzdomain.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS4: ID-mapping Problem with Linux Client and NetApp Server
References: <20120208144923.GA16606@geggus.net>
In-Reply-To: <20120208144923.GA16606@geggus.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/08/12 09:49, Sven Geggus wrote:

> Hello,
> 
> I'm trying to set up a couple of Active-directory integrated Linux machines
> using NFS4 volumes on a NetApp Server as storage media.
> 
> So far, I'm nearly there, but the final step seems to be missing:
> 
> My client (Debian GNU/Linux with nfs-utils 1.2.5) can mount the NetApp
> Emulator and Users are managed completely by AD Objects using nslcd.
> 
> Now I try to mount the NetApp Emulator vis NFS4 as root:
> 
> mount  -t nfs4 -o sec=krb5 dataontap-801.<fqdn>:/vol/v_testhome1/testhome1 /mnt/
> 
> This also works, however the NetApp is printing some strange warning:
> 
> [nfsd.rpc.request.bad:warning]: Client 10.1.7.174 is sending bad rpc requests with error: RPC version mismatch or authentication error(73)
> [nfsd.auth.status.bad:warning]: Client 10.1.7.174 has an authentication error 2


This does look suspicious... using wireshark, can you look at a packet sent by the client to the server.  Under "Remote Procedure Call", check that check the "Credentials" have kerberos.  Also check the server configuration to make sure that krb5 is allowed and using the DES-CBC-CRC enctype.

> 
> This is probably harmless and caused by the local root which does not have a
> valid AD account.
> 
> After the mount I can successfully browse the volume as user and my machine
> is even able to read/write files to/from the server.
> 
> However the files are not owned by the correct users. Server is just sending
> me invalid stuff.
> 
> Here is the owner string I get from the server looking into the packets using
> wireshark:
> 
> ...
> recc_attr: FATTR4_OWNER (36)
>     fattr4_owner: root@<fqdn>
>         length: 19
>         contents: root@<fqdn>
>         fill bytes: opaque data
> recc_attr: FATTR4_OWNER_GROUP (37)
>     fattr4_owner_group: nobody
>         length: 6
>         contents: nobody
>         fill bytes: opaque data


The idmapper usually maps users to "nobody" when they don't exist.  My best guess is that your problem has something to do with your kerberos configuration.  Is the client in the keytab?  I don't know how much of this blog post still applies, but at once point what you're trying to do was possible: http://nfsworld.blogspot.com/2005/06/using-active-directory-as-your-kdc-for.html.  It was written about Fedora-based machines, so some of the commands may be different on debian.

> 
> However checking with Windows and SMB these files are not owned by root but
> rather by the user which is trying to access the server.
> 
> On a Linux machine I would now try to run the server side rpc.idmapd with
> verbose options, but unfortunately with NetApp I don't know exactly what to do.
> 
> So, any hint what I am missing here?
> 
> Client side userid mapping seems to work fine, as I can seen something like
> this wehen running rpc.idmapd in verbose mode:
> 
> rpc.idmapd: Client 11: (user) name "root@<fqdn>" -> id "0"
> rpc.idmapd: Client 11: (group) name "nobody" -> id "65534"
> 
> Regards
> 
> Sven
> 


