Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:34792 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751800AbbJBOAo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2015 10:00:44 -0400
From: Andrew W Elble <aweits@rit.edu>
To: <linux-nfs@vger.kernel.org>
Subject: Re: 4.1.6 nfs client crash
References: <m2y4fla36p.fsf@discipline.rit.edu>
Date: Fri, 02 Oct 2015 10:00:43 -0400
In-Reply-To: <m2y4fla36p.fsf@discipline.rit.edu> (Andrew W. Elble's message of
	"Fri, 2 Oct 2015 08:02:38 -0400")
Message-ID: <m2bnch9xpw.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> [315893.215486] WARNING: CPU: 32 PID: 3056 at lib/list_debug.c:36 __list_add+0x92/0xc0()
...
> [315893.439206]  [<ffffffffa073cba8>] nfs4_put_state_owner+0x58/0x70 [nfsv4]
> [315893.448473]  [<ffffffffa073d227>] nfs4_do_reclaim+0x137/0x630 [nfsv4]

That nfs4_put_state_owner() in nfs4_do_reclaim() is this one, by the
way (I have a dump available)

nfs4_put_state_owner(sp);
goto restart;

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
