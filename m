Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42331 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753936Ab3IEVkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 17:40:03 -0400
Date: Thu, 5 Sep 2013 17:40:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Emmanuel Florac <eflorac@intellique.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Hard to debug NFS loss of connectivity
Message-ID: <20130905214002.GD24805@fieldses.org>
References: <20130905191800.1c75b2fb@harpe.intellique.com>
 <20130905204536.GB24805@fieldses.org>
 <20130905233449.5eb8bf79@galadriel.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130905233449.5eb8bf79@galadriel.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 05, 2013 at 11:34:49PM +0200, Emmanuel Florac wrote:
> Le Thu, 5 Sep 2013 16:45:36 -0400 vous écriviez:
> 
> > Well, it sounds like you have a reproducer that shouldn't be *too*
> > huge (the test where it freezes after stat'ing 25 files).
> > 
> > What do you see on the network in that case?
> 
> I didn't look yet what's actually happening, out of the drop in network
> throughput.
>  
> > Are you literally using just tcpdump?  Wireshark will give more
> > (and easier to read) information.
> 
> I didn't install tcpdump yet, but isn't wireshark with a GUI? I can't
> run anything with a GUI, this is a remote site behind several ssh
> portals. So I should run tshark, then get my hands on the results to
> analyze them with wireshark on my PC. Will try that.

Right, I just do "tcpdump -s0 -wtmp.pcap -i<interface>" and then run
wireshark on tmp.pcap.

> > Does the server stop responding at some point, or reply with an error?
> 
> No response. I don't know if the server actually stops responding or if
> something's wrong on the client side. Unfortunately I don't have
> access to any other NFS client on this network, out of this VM and the
> server itself. When rebooting the VM reconnects to the server  all by
> itself, so the server most probably is OK at all times.
> 
> > Or does the getattr reply on the problem file look odd in any way?
> 
> Not odd at all; it just stops after a particular file, though this file
> and the following files can be accessed OK before I run the failing
> test.

I was asking about the on-the-wire errors and getattr replies here, not
the application system calls.

--b.
