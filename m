Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tuna.sandelman.ca ([209.87.252.184]:46762 "EHLO
	tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755806Ab3GZOch (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jul 2013 10:32:37 -0400
From: Michael Richardson <mcr@sandelman.ca>
To: Peter Funk <pf@artcom-gmbh.de>
cc: Dick Streefland <dick.streefland@altium.nl>, linux-nfs@vger.kernel.org
Subject: Re: How to avoid rebooting Linux NFS-client when NFS-server is not available?
In-Reply-To: <20130726120849.GA12584@pfmaster>
References: <20130724091856.GA30866@pfmaster> <6f01.51efd09f.c2ac3@altium.nl> <20130726120849.GA12584@pfmaster>
Date: Fri, 26 Jul 2013 10:31:13 -0400
Message-ID: <333.1374849073@sandelman.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Peter Funk <pf@artcom-gmbh.de> wrote:
    > Indeed: This workaround seems to work!

    > Assume example: The NFS-server has IP 192.168.123.45 and the client
    > has also the nfs-kernel-server package installed and it is running.
    > Then this sequence on the client did the trick::

    > ifconfig eth0:fakesrv 192.168.123.45 up
    > umount -f -l ....
    > umount -f -l ....
    > ....
    > ifconfig eth0:fakesrv down

Good idea, but I suggest doing it on lo rather than eth0.

