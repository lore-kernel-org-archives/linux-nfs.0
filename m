From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Best solution for following problem...
Date: Sat, 31 Oct 2009 15:41:54 -0400
Message-ID: <1257018114.3928.30.camel@heimdal.trondhjem.org>
References: <4AEC85C8.4030405@aster.pl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Piotr Oniszczuk <piotr.oniszczuk-upgw/6zDzsc@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:56528 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933187AbZJaTlx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 31 Oct 2009 15:41:53 -0400
In-Reply-To: <4AEC85C8.4030405-upgw/6zDzsc@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-10-31 at 19:45 +0100, Piotr Oniszczuk wrote:
> Hi *
> 
> I'm looking for advice for best solution for following problem:
> 
> I have file server sharing files to diskless clients via NFS
> 
> I want  have setup, where pluging ext. USB HDD will be dynamically 
> visible on clients as new <subdir> with HDD contents.
> So if user plug USB HD on server, diskless clients should see plugged 
> HDD contents in dynamically created <subdirectory> with name equal to HD 
> label and HD contents inside it.
> 
> I already wrote udev script which auto creates subdir=<label> in NFS 
> server shared dir, and automounts USB HD in this subdir.
> 
> Issue is that diskless clients don't see this subdir  unless  I issue on 
> server
> 
> exportfs -ua
> exportfs -a
> 
> Problem is that  above unexporting/exporting sequence issued on server 
> brokes existing NFS shares between clients and server.
> 
> What is most elegant solution for such functional requirement ?

<changed mailing list address to correct one for linux-nfs>

Doesn't 'exportfs -r' work for you?

Cheers
  Trond

