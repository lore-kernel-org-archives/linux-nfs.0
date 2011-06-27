Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cmx.pixar.com ([12.25.180.66]:57604 "EHLO cmx.pixar.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753394Ab1F0SZS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jun 2011 14:25:18 -0400
Message-ID: <4E08C8BE.2000407@pixar.com>
Date: Mon, 27 Jun 2011 11:15:26 -0700
From: Joe Frost <joef@pixar.com>
To: linux-nfs@vger.kernel.org
Subject: Mounstats keying on fsid or ipaddr?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We've been using mountstats to graph/track NFS usage based on path. 
We've recently made some changes on how we mount filesystems here where 
it's possible the same IP will be used for multiple mounts. Since that 
we've noticed that all mounts to the same IPaddr are showing the same 
statistics. Wondering if anyone had ideas why it might be keying off of 
IPaddr?

Below are some relevant configuration files:


Automount configuration for path /shows/movie/$key

ribcage              -rw,intr,rsize=131072,wsize=524288,tcp 
primary.carrots:/ifs/shows/movie/ribcage
convert              -rw,intr,rsize=131072,wsize=524288,tcp 
primary.carrots:/ifs/shows/movie/convert
shottmp              -rw,intr,rsize=131072,wsize=524288,tcp 
primary.carrots:/ifs/shows/movie/shottmp

Proc/mounts on a particular server:

primary.carrots:/ifs/shows/movie/shottmp on /shows/movie/shottmp type 
nfs 
(rw,noatime,intr,tcp,intr,rsize=131072,wsize=524288,tcp,sloppy,addr=10.73.6.89)
primary.carrots:/ifs/shows/movie/ribcage on /shows/movie/ribcage type 
nfs 
(rw,noatime,intr,tcp,intr,rsize=131072,wsize=524288,tcp,sloppy,addr=10.73.6.89)
primary.carrots:/ifs/shows/movie/convert on /shows/movie/convert type 
nfs 
(rw,noatime,intr,tcp,intr,rsize=131072,wsize=524288,tcp,sloppy,addr=10.73.6.89)



We're using Isilon as the filer:

carrots-1# isi nfs exports list
    Rule ID   Paths                                             Comment 

           11  /ifs/shows/brave/convert                       convert
           16  /ifs/shows/movie/ribcage                       ribcage
           17  /ifs/shows/movie/shottmp                       shottmp
