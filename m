Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62058 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781Ab1LOQLl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2011 11:11:41 -0500
Message-ID: <1323965498.14317.13.camel@lade.trondhjem.org>
Subject: RE: copy offload support in Linux - new system call needed?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Ric Wheeler <ricwheeler@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-scsi@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 15 Dec 2011 11:11:38 -0500
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B91516E391@nsmail.netscout.com>
References: <4EE8F75F.6070800@gmail.com>
	 <20111214192739.GN2203@ZenIV.linux.org.uk> <4EE8FC2E.3010207@gmail.com>
	 <20111214222723.GD7623@fieldses.org>
	 <1323961140.14317.2.camel@lade.trondhjem.org>
	 <D3F292ADF945FB49B35E96C94C2061B91516E391@nsmail.netscout.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-12-15 at 11:08 -0500, Loke, Chetan wrote: 
> > How would the server know? I suggest we deal with this by adding an
> > ioctl() to allow the application to poll for progress: I'm assuming now
> 
> Why not support something like the async-iocb?

You could, but that would tie copyfile() to the aio interface which was
one of the things that I believe Al was opposed to when we discussed
this at LSF/MM-2010.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

