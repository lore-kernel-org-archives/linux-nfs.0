Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38709 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363AbZBDXTz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2009 18:19:55 -0500
Date: Wed, 4 Feb 2009 18:19:58 -0500
To: Krishna Kumar <krkumar2@in.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 0/1] nfsd: Improve NFS server performance
Message-ID: <20090204231958.GB20917@fieldses.org>
References: <20081230104245.9409.30030.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20081230104245.9409.30030.sendpatchset@localhost.localdomain>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Dec 30, 2008 at 04:12:45PM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>

Thanks for the work, and apologies for the slow response.

> 
> Patch summary:
> --------------
> Change the readahead caching on the server to a file handle caching model.
> Since file handles are unique, this patch removes all dependencies on the
> kernel readahead parameters/implementation and instead caches files based
> on file handles. This change allows the server to not have to open/close
> a file multiple times when the client reads it, and results in faster lookup
> times.

I think of open and lookup as fairly fast, so I'm surprised this makes a
great difference; do you have profile results or something to confirm
that this is in fact what made the difference?

> Also, readahead is automatically taken care of since the file is not
> closed while it is getting read (quickly) by the client.
> 
> 
> Read algo change:
> ------------------
> The new nfsd_read() is changed to:
> 	if file {
> 		Old code
> 	} else {
> 		Check if this FH is cached
> 		if fh && fh has cached file pointer:
> 			Get file pointer
> 			Update fields in fhp from cache
> 			call fh_verify
> 		else:
> 			Nothing in the cache, call nfsd_open as usual
> 
> 		nfsd_vfs_read
> 
> 		if fh {
> 			If this is a new fh entry:
> 				Save cached values
> 			Drop our reference to fh
> 		} else
> 			Close file
> 	}

When do items get removed from this cache?

> 
> 
> Performance:
> -------------
> This patch was tested with clients running 1, 4, 8, 16 --- 256 test processes,
> each doing reads of different files. Each test includes different I/O sizes.
> Many individual tests (16% of test cases) got throughput improvement in the
> 9 to 15% range. The full results are provided at the end of this post.

Could you provide details sufficient to reproduce this test if
necessary?  (At least: what was the test code, how many clients were
used, what was the client and server hardware, and what filesystem was
the server exporting?)

--b.

> 
> Please review. Any comments or improvement ideas are greatly appreciated.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> 
> 		(#Test Processes on Client == #NFSD's on Server)
> --------------------------------------------------------------
> #Test Processes		Org BW KB/s	New BW KB/s	%
> --------------------------------------------------------------

What's the second column?

> 4	256		48151.09	50328.70	4.52
> 4	4096		47700.05	49760.34	4.31
> 4	8192		47553.34	48509.00	2.00
> 4	16384		48764.87	51208.54	5.01
> 4	32768		49306.11	50141.59	1.69
> 4	65536		48681.46	49491.32	1.66
> 4	131072		48378.02	49971.95	3.29
> 
> 8	256		38906.95	42444.95	9.09
> 8	4096		38141.46	42154.24	10.52
> 8	8192		37058.55	41241.78	11.28
> 8	16384		37446.56	40573.70	8.35
> 8	32768		36655.91	42159.85	15.01
> 8	65536		38776.11	40619.20	4.75
> 8	131072		38187.85	41119.04	7.67
> 
> 16	256		36274.49	36143.00	-0.36
> 16	4096		34320.56	37664.35	9.74
> 16	8192		35489.65	34555.43	-2.63
> 16	16384		35647.32	36289.72	1.80
> 16	32768		37037.31	36874.33	-0.44
> 16	65536		36388.14	36991.56	1.65
> 16	131072		35729.34	37588.85	5.20
> 
> 32	256		30838.89	32811.47	6.39
> 32	4096		31291.93	33439.83	6.86
> 32	8192		29885.57	33337.10	11.54
> 32	16384		30020.23	31795.97	5.91
> 32	32768		32805.03	33860.68	3.21
> 32	65536		31275.12	32997.34	5.50
> 32	131072		33391.85	34209.86	2.44
> 
> 64	256		26729.46	28077.13	5.04
> 64	4096		25705.01	27339.37	6.35
> 64	8192		27757.06	27488.04	-0.96
> 64	16384		22927.44	23938.79	4.41
> 64	32768		26956.16	27848.52	3.31
> 64	65536		27419.59	29228.76	6.59
> 64	131072		27623.29	27651.99	.10
> 
> 128	256		22463.63	22437.45	-.11
> 128	4096		22039.69	22554.03	2.33
> 128	8192		22218.42	24010.64	8.06
> 128	16384		15295.59	16745.28	9.47
> 128	32768		23319.54	23450.46	0.56
> 128	65536		22942.03	24169.26	5.34
> 128	131072		23845.27	23894.14	0.20
> 
> 256	256		15659.17	16266.38	3.87
> 256	4096		15614.72	16362.25	4.78
> 256	8192		16950.24	17092.50	0.83
> 256	16384		9253.25		10274.28	11.03
> 256	32768		17872.89	17792.93	-.44
> 256	65536		18459.78	18641.68	0.98
> 256	131072		19408.01	20538.80	5.82
> --------------------------------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
