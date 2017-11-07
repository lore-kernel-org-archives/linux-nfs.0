Return-Path: <aweits@rit.edu>
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: bcodding redhat <bcodding@redhat.com>,
  "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
  "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 00/11] Fix OPEN/CLOSE races
References: <20171106202811.70202-1-trond.myklebust@primarydata.com>
	<m2vainowk1.fsf@discipline.rit.edu>
	<1510008607.3861.1.camel@primarydata.com>
	<m2y3ninhxs.fsf@discipline.rit.edu>
	<1510079753.7834.7.camel@primarydata.com>
	<1510081247.7834.9.camel@primarydata.com>
Date: Tue, 07 Nov 2017 18:03:27 -0500
In-Reply-To: <1510081247.7834.9.camel@primarydata.com> (Trond Myklebust's
	message of "Tue, 7 Nov 2017 19:00:49 +0000")
Message-ID: <m2inelofnk.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trondmy@primarydata.com> writes:

> On Tue, 2017-11-07 at 18:35 +0000, Trond Myklebust wrote:
>> 
>> Ah, I see. Can we in that case please rather do the following?
>> 
>> 
>
> ...and then follow up with:
>
> 8<--------------------------------------------------------------
> From 545e2fddb72268f5c59a3986169af96a40a6aab0 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Tue, 7 Nov 2017 12:39:44 -0500
> Subject: [PATCH 2/2] NFSv4: Replace closed stateids with the "invalid special
>  stateid"
>
> When decoding a CLOSE, replace the stateid returned by the server
> with the "invalid special stateid" described in RFC5661, Section 8.2.3.
>
> In nfs_set_open_stateid_locked, ignore stateids from closed state.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Looks good! Thanks!

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
