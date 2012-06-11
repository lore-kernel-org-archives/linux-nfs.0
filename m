Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ferdi.naasa.net ([87.106.227.76]:39795 "EHLO ferdi.naasa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753467Ab2FKQFL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Jun 2012 12:05:11 -0400
Message-ID: <4FD614F2.2090700@jako.ping.de>
Date: Mon, 11 Jun 2012 17:55:30 +0200
From: Joerg Platte <jplatte@jako.ping.de>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: =?UTF-8?B?SsO2cmcgUGxhdHRl?= <jplatte@naasa.net>,
        bfields <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Hans de Bruin <jmdebruin@xmsnet.nl>
Subject: Re: Kernel 3.4.X NFS server regression
References: <4FD47D4E.9070307@naasa.net> <1339340441.4751.1.camel@lade.trondhjem.org> <20120611121634.GB7654@fieldses.org> <20120611083932.24e27e39@corrin.poochiereds.net> <20120611091338.1c88e6d0@corrin.poochiereds.net> <E49E5D8F-3647-4B3D-989E-FE4476D37607@naasa.net> <20120611102016.3114349d@corrin.poochiereds.net>
In-Reply-To: <20120611102016.3114349d@corrin.poochiereds.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11.06.2012 16:20, Jeff Layton wrote:
> No problem. One possibility for the difference is that rpc_pipefs is
> mounted on the machine that doesn't show the problem, but isn't mouted
> on the machine that does.

Just for the records, after creating the v4recovery directory the 
problem is gone. Currently I don't understand who has deleted the 
directory (possibly me :) ), since it is part of the already installed 
nfs-server package...

I'll check your patch later because my build host is rather slow...

regards,
Joerg

