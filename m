Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f52.google.com ([209.85.214.52]:45386 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab3BVSZ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2013 13:25:27 -0500
Received: by mail-bk0-f52.google.com with SMTP id jk13so415426bkc.25
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2013 10:25:26 -0800 (PST)
Message-ID: <5127B813.5040601@gmail.com>
Date: Fri, 22 Feb 2013 19:25:23 +0100
From: poma <pomidorabelisima@gmail.com>
MIME-Version: 1.0
To: Community support for Fedora users <users@lists.fedoraproject.org>
CC: Greg Scott <GregScott@infrasupport.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: What does "mapping=identity" mean in /etc/exports?
References: <1470031369de4d60a0d5965ec6bede10@mail2013.infrasupport.local>
In-Reply-To: <1470031369de4d60a0d5965ec6bede10@mail2013.infrasupport.local>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/16/13 22:09, Greg Scott wrote:
> Hello -
> 
> I'm migrating an old NFS server to newer hardware.  /etc/exports in the old environment looks like this:
> 
> /shares/IMSHCS01        *(rw,insecure,sync,no_root_squash,all_squash,mapping=identity,anonuid=0,anongid=0
> 
> So the old system is exporting the directory, /shares/IMSHCS01 to anyone and everyone who wants to connect, with a bunch of switches essentially making it wide open.
> 
> Wonderful.  
> 
> But on the new system, when I set up  /etc/exports the same way, I get this error: 
> 
> [root@nfs2013 etc]# exportfs -av
> exportfs: /etc/exports:1: unknown keyword "mapping=identity"
> 
> [root@nfs2013 etc]#
> 
> Getting rid of "mapping=identity", my shared directory exports just fine.  
> 
> I can find no mention of "mapping=identity" in any man pages, but several google references show this option in pasted-in copies of /etc/exports files.  My hunch is, this is an obsolete option and no longer supported - but what did it do in case my new server needs to behave the same way the old server behaved?
> 

Probably related to the unfsd[1].
iSeries? ;)

[1]
http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commitdiff;h=74a8f33de5f26d6bab11d5299318035d65bd60d0;hp=afc841a1f2a62645ec2dfaa333baf07e44a03c08


Cheers,
poma

