Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60200 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934640AbcCOPSf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2016 11:18:35 -0400
Date: Tue, 15 Mar 2016 11:18:33 -0400
To: Sascha Frey <sfrey@TechFak.Uni-Bielefeld.DE>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 I/O error when reading a file which was deleted and
 recreated by another client
Message-ID: <20160315151833.GD419@fieldses.org>
References: <20160315092104.GF6542@TechFak.Uni-Bielefeld.DE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160315092104.GF6542@TechFak.Uni-Bielefeld.DE>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 15, 2016 at 10:21:04AM +0100, Sascha Frey wrote:
> Hi list,
> 
> we're experiencing a serious NFSv4 client caching issue when a
> client reads a file which was deleted and recreated by another client.
> 
> Steps to reproduce the problem:
> 
> root@client1:~# mount -t nfs -o rw,vers=4,sec=sys,hard,intr 129.70.150.53:/vol/testvol5 /mnt
> root@client2:~# mount -t nfs -o rw,vers=4,sec=sys,hard,intr 129.70.150.53:/vol/testvol5 /mnt
> 
> user@client1:~$ echo foo > /mnt/bar
