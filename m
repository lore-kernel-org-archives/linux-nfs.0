Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:38336 "EHLO mail.aixigo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753019AbcALMc6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jan 2016 07:32:58 -0500
Subject: Re: Debian kernel:
To: PIERRRE <pierref@buf.com>, linux-nfs@vger.kernel.org
References: <55C3016A.9000509@aixigo.de>
 <20150811090949.5f1a2594@dpcl082.ac.aixigo.de>
 <loom.20160107T193055-318@post.gmane.org>
From: Harald Dunkel <harald.dunkel@aixigo.de>
Message-ID: <5694F0E8.1060400@aixigo.de>
Date: Tue, 12 Jan 2016 13:26:16 +0100
MIME-Version: 1.0
In-Reply-To: <loom.20160107T193055-318@post.gmane.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Pierre,

On 01/07/2016 07:34 PM, PIERRRE wrote:
> 
> Hi,
> 
> I have the same issue with several NFS servers. Cannot find any help.
> 
> How did you fixed it with grub ?

I set
	GRUB_CMDLINE_LINUX="nfs.nfs4_unique_id=e2177c92-1fe6-48db-918b-ddefba900379"

in /etc/default/grub and rebuild the grub.cfg file.

The important point is that every NFS client and every root
partition get its own unique id. Be careful, especially if
you clone your hosts.

You can generate a new ID using uuidgen on the command line.


Hope this helps
Harri

