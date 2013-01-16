Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41582 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808Ab3APTji (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2013 14:39:38 -0500
Date: Wed, 16 Jan 2013 14:39:32 -0500
To: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        baggins@pld-linux.org, Trond.Myklebust@netapp.com
Subject: Re: mount.nfs: cannot allocate memory.
Message-ID: <20130116193932.GA5002@fieldses.org>
References: <2891788.0SBnrhN2VX@pawels>
 <50EADFED.1070505@RedHat.com>
 <2367820.SDlsSOm8Xm@localhost>
 <1435172.ktCUaNjhdC@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1435172.ktCUaNjhdC@localhost>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 16, 2013 at 08:03:14PM +0100, Paweł Sikora wrote:
> [259176.973751] NFS: nfs mount opts='soft,addr=10.0.2.28,vers=3,proto=tcp,mountvers=3,mountproto=udp,mountport=50252'
> [259176.973757] NFS:   parsing nfs mount option 'soft'
> [259176.973759] NFS:   parsing nfs mount option 'addr=10.0.2.28'
> [259176.973765] NFS:   parsing nfs mount option 'vers=3'
> [259176.973769] NFS:   parsing nfs mount option 'proto=tcp'
> [259176.973772] NFS:   parsing nfs mount option 'mountvers=3'
> [259176.973776] NFS:   parsing nfs mount option 'mountproto=udp'
> [259176.973779] NFS:   parsing nfs mount option 'mountport=50252'
> [259176.973784] NFS: MNTPATH: '/R10'
> [259176.973788] NFS: sending MNT request for nexus:/R10
> [259176.974620] NFS: received 1 auth flavors
> [259176.974623] NFS:   auth flavor[0]: 1
> [259176.974640] NFS: MNT request succeeded
> [259176.974643] NFS: using auth flavor 1
> [259176.974688] --> nfs_init_server()
> [259176.974691] --> nfs_get_client(nexus,v3)
> [259176.974698] NFS: get client cookie (0xffff88021146f800/0xffff8800ceb06640)
> [259176.975704] <-- nfs_init_server() = 0 [new ffff88021146f800]
> [259176.975708] --> nfs_probe_fsinfo()
> [259176.975711] NFS call  fsinfo
> [259176.975959] NFS reply fsinfo: -116

That's ESTALE.  Might be interesting to see the network traffic between
client and server.

--b.

> [259176.975963] NFS call  fsinfo
> [259176.976182] NFS reply fsinfo: -116
> [259176.976184] nfs_probe_fsinfo: error = 116
> [259176.976186] --> nfs_free_server()
> [259176.976282] --> nfs_put_client({1})
> [259176.976285] --> nfs_free_client(3)
> [259176.976287] NFS: releasing client cookie (0xffff88021146f800/0xffff8800ceb06640)
> [259176.976308] <-- nfs_free_client()
> [259176.976322] <-- nfs_free_server()
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
