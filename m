Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53407 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043Ab1LHVwl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Dec 2011 16:52:41 -0500
Date: Thu, 8 Dec 2011 16:52:39 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Posonsky <psk@cpositive.ru>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Error: state manager failed on NFSv4 server base with error
 10018
Message-ID: <20111208215239.GJ32505@fieldses.org>
References: <201109211334.34497.psk@cpositive.ru>
 <20110921160020.GD21510@fieldses.org>
 <201109221142.25798.psk@cpositive.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <201109221142.25798.psk@cpositive.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, I just noticed I'd dropped this; could you retest with either the
latest -rc or with

	git://linux-nfs.org/~bfields/linux.git master

on the server side?

There have been a lot of changes in that area.

--b.

On Thu, Sep 22, 2011 at 11:42:25AM +0900, Stanislav Posonsky wrote:
> On Thursday 22 of September 2011 01:00:20 you wrote:
> > On Wed, Sep 21, 2011 at 01:34:34PM +0900, Stanislav Posonsky wrote:
> > > 	After upgrade kernel at server from 2.6.38 to 2.6.39 series and higher,
> > > 
> > > I was forced to drop to NFSv3. With NFSv4 I get (when I trying to read
> > > any
> > > 
> > > file) hundreds message at client:
> > > 	Error: state manager failed on NFSv4 server base with error 10018
> > > 	
> > > 	Now I have at server and cient:
> > > 	
> > > 	linux kernel 	3.0.4
> > > 	nfs-utils		1.2.3
> > > 	nfs4-acl-tools	0.3.3
> > > 
> > > 	File /etc/exports:
> > > /opt                        192.168.8.0/24(fsid=0,rw,subtree_check)
> > > 
> > > ==================================================
> > > 
> > > 	With version 3
> > > 
> > > ==================================================
> > > 
> > > root|st01# mount -t nfs -o nfsvers=3 base:/opt /net
> > > root|st01# mount | grep nfs
> > > rpc_pipefs on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
> > > base:/opt on /net type nfs (rw,nfsvers=3,addr=192.168.8.254)
> > > 
> > > 	In other console:
> > > stas@st01$ ls -l /net/a*
> > > -rw-r--r-- 1 root root 35 Сен 21 11:23 /net/a_file.txt
> > > stas@st01$ cat /net/a_file.txt
> > > This is a test file on NFS share.
> > > 
> > > stas@st01$
> > > 
> > > 	Works fine.
> > > 
> > > ==================================================
> > > 
> > > 	With version 4
> > > 
> > > ==================================================
> > > 
> > > root|st01# umount /net
> > > root|st01# mount -t nfs base:/ /net
> > > root|st01# mount | grep nfs
> > > rpc_pipefs on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
> > > base:/ on /net type nfs
> > > (rw,vers=4,addr=192.168.8.254,clientaddr=192.168.8.1)
> > > 
> > > 	In other console:
> > > stas@st01$ ls -l /net/a*
> > > -rw-r--r-- 1 root root 35 Сен 21 11:23 /net/a_file.txt
> > > stas@st01$ cat /net/a_file.txt
> > > 
> > > 	And the process hangs... Then (Ctl+C):
> > > ^C
> > > stas@st01$ dmesg
> > > Error: state manager failed on NFSv4 server base with error 10018
> > > Error: state manager failed on NFSv4 server base with error 10018
> > > ...
> > > 
> > > Could you help me solve this problem, please?
> > 
> > Could you get a network trace showing the "With version 4" case?
> > 
> > (tcpdump -s0 -wtmp.pcap, then run your test, then kill tcpdump and mail
> > me tmp.pcap)
> 
> 	Yes, certainly. Two files are in attachment - at "mount" and "cat" 
> stages.
> -- 
>   With best regards, Stanislav



