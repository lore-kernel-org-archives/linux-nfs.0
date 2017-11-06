Return-Path: <aweits@rit.edu>
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
  Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 00/11] Fix OPEN/CLOSE races
References: <20171106202811.70202-1-trond.myklebust@primarydata.com>
Date: Mon, 06 Nov 2017 17:46:06 -0500
In-Reply-To: <20171106202811.70202-1-trond.myklebust@primarydata.com> (Trond
	Myklebust's message of "Mon, 6 Nov 2017 15:28:00 -0500")
Message-ID: <m2vainowk1.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trond.myklebust@primarydata.com> writes:

> v8:
> - Really fix compile issue when CONFIG_NFS_V4_1=n
> - nfs_inode_find_state_and_recover() should also try to match the
>   open_stateid.

Seeing a lot of TEST_STATEID's for the invalid stateid go over the
wire - this also makes the server hit this quite a bit:

pr_warn_ratelimited("NFSD: client %s testing state ID "
                        "with incorrect client ID\n", addr_str);

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
